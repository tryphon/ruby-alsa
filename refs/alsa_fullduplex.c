/* 
   ciacciax@yahoo.com 
   http://mailman.alsa-project.org/pipermail/alsa-devel/2007-May/001100.html

   gcc -o alsa_fullduplex -lasound alsa_fullduplex.c
 */

#include <sys/time.h>
#include <sys/resource.h>
#include <alsa/asoundlib.h>
#include <stdio.h>
#include <math.h>

#define PLAYBACK		0
#define CAPTURE			1
#define CARD			"hw:0,0"

static snd_pcm_format_t format = SND_PCM_FORMAT_S16_LE;	/* sample format */
static unsigned int rate = 44100;			/* stream rate */
static snd_pcm_uframes_t period_size = 512;		/* period size */
static short buffer[512];

typedef void (*area_callback)(const snd_pcm_channel_area_t*, snd_pcm_uframes_t, int);

void capture_area(const snd_pcm_channel_area_t *areas, snd_pcm_uframes_t offset, int count);
void playback_area(const snd_pcm_channel_area_t *areas, snd_pcm_uframes_t offset, int count);

struct STREAM_DESC {
	char *name;
	snd_pcm_stream_t stream;
	area_callback func;
	unsigned short poll_flag;
};

struct STREAM_DESC descriptors[2] = {
	{ .name = "PLAYBACK",
	  .stream = SND_PCM_STREAM_PLAYBACK,
	  .func = playback_area,
	  .poll_flag = POLLOUT,
	}, 
	{ .name = "CAPTURE",
	  .stream = SND_PCM_STREAM_CAPTURE,
	  .func = capture_area,
	  .poll_flag = POLLIN,
	}
};

void capture_area(const snd_pcm_channel_area_t *areas, 
		snd_pcm_uframes_t offset, int count)
{
	short *isamples;		// interleaved samples
	short *dst;

	assert(areas[0].first == 0);
	assert(areas[0].step == 2 * 8 * sizeof(short));
	assert(areas[1].first == 8 * sizeof(short));
	assert(areas[1].step == 2 * 8 * sizeof(short));
	assert(areas[0].addr == areas[1].addr);
	assert(count == 512);

	isamples = (short *)areas[0].addr + offset * 2; // offset for two interleaved channels
	dst = buffer;

	while (count-- > 0)
	{	
		*dst++ = (short)*isamples;
		isamples++;
		isamples++;
	}
}

void playback_area(const snd_pcm_channel_area_t *areas, 
		snd_pcm_uframes_t offset, int count)
{
	short *isamples;		// interleaved samples
	short *src;

	assert(areas[0].first == 0);
	assert(areas[0].step == 2 * 8 * sizeof(short));
	assert(areas[1].first == 8 * sizeof(short));
	assert(areas[1].step == 2 * 8 * sizeof(short));
	assert(areas[0].addr == areas[1].addr);
	assert(count == 512);

	isamples = (short *)areas[0].addr + offset * 2; // offset for two interleaved channels
	src = buffer;

	while (count-- > 0)
	{	
		*isamples++ = *src;
		*isamples++ = *src;
		src++;
	}	
}

/*
 *   Underrun and suspend recovery
 */
static int xrun_recovery(snd_pcm_t *handle, int err)
{
	printf("xrun_recovery...\n");
	if (err == -EPIPE) {    /* under-run */
		err = snd_pcm_prepare(handle);
		if (err < 0)
			printf("Can't recovery from underrun, prepare failed: %s\n", snd_strerror(err));
		return 0;
	} else if (err == -ESTRPIPE) {
		while ((err = snd_pcm_resume(handle)) == -EAGAIN)
			sleep(1);       /* wait until the suspend flag is released */
		if (err < 0) {
			err = snd_pcm_prepare(handle);
			if (err < 0)
				printf("Can't recovery from suspend, prepare failed: %s\n", snd_strerror(err));
		}
		return 0;
	}
	return err;
}

int setparams(const char *name, snd_pcm_t **handle, snd_pcm_stream_t stream)
{
	int err, dir;
	unsigned int rrate;
	snd_pcm_hw_params_t *hw_params;

	snd_pcm_uframes_t buffer_size;

	if ((err = snd_pcm_open (handle, name, stream, SND_PCM_NONBLOCK)) < 0) {
		fprintf (stderr, "cannot open audio device %s (%s)\n", 
			name,
			snd_strerror (err));
		return err;
	}
	
	if ((err = snd_pcm_hw_params_malloc (&hw_params)) < 0) {
		fprintf (stderr, "cannot allocate hardware parameter structure (%s)\n",
			snd_strerror (err));
		return err;
	}
			
	if ((err = snd_pcm_hw_params_any (*handle, hw_params)) < 0) {
		fprintf (stderr, "cannot initialize hardware parameter structure (%s)\n",
			snd_strerror (err));
		return err;
	}

	if ((err = snd_pcm_hw_params_set_access (*handle, hw_params, SND_PCM_ACCESS_MMAP_INTERLEAVED)) < 0) {
		fprintf (stderr, "cannot set access type (%s)\n",
			snd_strerror (err));
		return err;
	}

	if ((err = snd_pcm_hw_params_set_format (*handle, hw_params, format)) < 0) {
		fprintf (stderr, "cannot set sample format (%s)\n",
			snd_strerror (err));
		return err;
	}

	// Rate
	rrate = rate;
	printf("Trying to set rate near %d\n", rrate);
	if ((err = snd_pcm_hw_params_set_rate_near (*handle, hw_params, &rrate, 0)) < 0) {
		fprintf (stderr, "cannot set sample rate (%s)\n",
			snd_strerror (err));
		return err;
	}
	printf("Rate set to %d\n", rrate);

	// Buffer (in frames size)
	printf("Trying to set buffer size %d\n", 1024);
	if ((err = snd_pcm_hw_params_set_buffer_size (*handle, hw_params, 1024)) < 0) {
		fprintf (stderr, "cannot set buffer size (%s)\n",
			snd_strerror (err));
		return err;
	}

	if ((err = snd_pcm_hw_params_get_buffer_size (hw_params, &buffer_size)) < 0) {
		fprintf (stderr, "cannot get buffer size (%s)\n",
			snd_strerror (err));
		return err;
	}
	printf("Buffer size set to %ld\n", buffer_size);

	printf("Trying to set period to %ld\n", period_size);
	dir = 0;
	if ((err = snd_pcm_hw_params_set_period_size (*handle, hw_params, period_size, dir)) < 0) {
		fprintf (stderr, "cannot set period_size (%s)\n",
			snd_strerror (err));
		return err;
	}
	printf("Period set to %ld\n", period_size);

	if ((err = snd_pcm_hw_params_set_channels (*handle, hw_params, 2)) < 0) {
		fprintf (stderr, "cannot set channel count (%s)\n",
			snd_strerror (err));
		return err;
	}

	if ((err = snd_pcm_hw_params (*handle, hw_params)) < 0) {
		fprintf (stderr, "cannot set parameters (%s)\n",
			snd_strerror (err));
		return err;
	}

	snd_pcm_hw_params_free (hw_params);

	if ((err = snd_pcm_prepare (*handle)) < 0) {
		fprintf (stderr, "cannot prepare audio interface for use (%s)\n",
			snd_strerror (err));
		return err;
	}
	return 0;
}

int transfer_loop(snd_pcm_t *handle, int *first, area_callback func)
{
	const snd_pcm_channel_area_t *my_areas;
	snd_pcm_uframes_t offset, frames, size;
	snd_pcm_sframes_t avail, commitres;
	snd_pcm_state_t state;
	int err;

	while (1) {
		state = snd_pcm_state(handle);
		if (state == SND_PCM_STATE_XRUN) {
			err = xrun_recovery(handle, -EPIPE);
			if (err < 0) {
				printf("XRUN recovery failed: %s\n", snd_strerror(err));
				return err;
			}
			*first = 1;
		} else if (state == SND_PCM_STATE_SUSPENDED) {
			err = xrun_recovery(handle, -ESTRPIPE);
			if (err < 0) {
				printf("SUSPEND recovery failed: %s\n", snd_strerror(err));
				return err;
			}
		}
		avail = snd_pcm_avail_update(handle);
		if (avail < 0) {
			err = xrun_recovery(handle, avail);
			if (err < 0) {
				printf("avail update failed: %s\n", snd_strerror(err));
				return err;
			}
			*first = 1;
			continue;
		}
		if (avail < period_size) {
			if (*first) {
				*first = 0;
				printf("snd_pcm_start\n");
				err = snd_pcm_start(handle);
				if (err < 0) {
					printf("Start error: %s\n", snd_strerror(err));
					exit(EXIT_FAILURE);
				}
			} else {
				// err = snd_pcm_wait(playback_handle, -1);
				// return to the main loop (poll)
 				return 0;
			}
			continue;
		}
		size = period_size;
		while (size > 0) {
			frames = size;
			err = snd_pcm_mmap_begin(handle, &my_areas, &offset, &frames);
			if (err < 0) {
				if ((err = xrun_recovery(handle, err)) < 0) {
					printf("MMAP begin avail error: %s\n", snd_strerror(err));
					exit(EXIT_FAILURE);
				}
				*first = 1;
			}

			func(my_areas, offset, frames);

			commitres = snd_pcm_mmap_commit(handle, offset, frames);
			if (commitres < 0 || (snd_pcm_uframes_t)commitres != frames) {
				if ((err = xrun_recovery(handle, commitres >= 0 ? -EPIPE : commitres)) < 0) {
					printf("MMAP commit error: %s\n", snd_strerror(err));
					exit(EXIT_FAILURE);
				}
				*first = 1;
			}
			size -= frames;
		}
	}
}

int main(int argc, char *argv[])
{
	int i, err;
	snd_pcm_t *handles[2];
	struct pollfd ufds[2];
	unsigned short revents;
	int first[2] = {1, 0};

	for (i = 0; i < 2; i++)
	{
		if (setparams(CARD, &handles[i], descriptors[i].stream) < 0)
		{
			printf("Could not initialize stream %s\n", descriptors[i].name); 
			exit(1);
		}

		assert(snd_pcm_poll_descriptors_count(handles[i]) == 1);
		if ((err = snd_pcm_poll_descriptors(handles[i], &ufds[i], 1)) < 0)
		{
			printf("Unable to obtain poll descriptors for stream %s\n", descriptors[i].name);
			exit(1);
		}
	}

	// The capture stream has to be started manually...
	err = snd_pcm_start(handles[CAPTURE]);
	if (err < 0)
	{
		printf("Start error: %s\n", snd_strerror(err));
		exit(EXIT_FAILURE);
	}

	while (1) {
		err = poll(ufds, 2, -1);

		for (i = 0; i < 2; i++)
		{
			if (snd_pcm_poll_descriptors_revents(handles[i], &ufds[i], 1, &revents) < 0)
			{
				printf("Error getting revents for %s\n", descriptors[i].name);
				exit(1);
			}
	
			if (revents & descriptors[i].poll_flag)
			{
				if (transfer_loop(handles[i], &first[i], descriptors[i].func) < 0)
				{
					printf("transfer_loop error for %s\n", descriptors[i].name);
					// TODO exit?!?
				}
        else {
          printf(".");
        }
			}
		}
	}

	for (i = 0; i < 2; i++)
	{
		snd_pcm_close (handles[i]);
	}
	exit (0);
}
