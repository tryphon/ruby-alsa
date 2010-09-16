#include <stdio.h>
#include <stdlib.h>
#include <alsa/asoundlib.h>
#include <unistd.h>

static void playback_callback(snd_async_handler_t *callback)
{
  snd_pcm_t *playback_handle = snd_async_handler_get_pcm(callback);
  void *buf = snd_async_handler_get_callback_private(callback);

  snd_pcm_sframes_t avail;
  int err;

  avail = snd_pcm_avail_update(playback_handle);
  while (avail >= 1024) {
    if ((err = snd_pcm_writei(playback_handle, buf, 1024)) != 1024) {
      fprintf (stderr, "write to audio interface failed (%s)\n",
               snd_strerror (err));
      exit (1);
    }
    avail = snd_pcm_avail_update(playback_handle);
  }
}
	      
main (int argc, char *argv[])
{
  int i;
  int err;
  short buf[1024];
  snd_pcm_t *playback_handle;
  snd_pcm_hw_params_t *hw_params;
	
  if ((err = snd_pcm_open (&playback_handle, argv[1], SND_PCM_STREAM_PLAYBACK, 0)) < 0) {
    fprintf (stderr, "cannot open audio device %s (%s)\n", 
             argv[1],
             snd_strerror (err));
    exit (1);
  }
		   
  if ((err = snd_pcm_hw_params_malloc (&hw_params)) < 0) {
    fprintf (stderr, "cannot allocate hardware parameter structure (%s)\n",
             snd_strerror (err));
    exit (1);
  }
				 
  if ((err = snd_pcm_hw_params_any (playback_handle, hw_params)) < 0) {
    fprintf (stderr, "cannot initialize hardware parameter structure (%s)\n",
             snd_strerror (err));
    exit (1);
  }
	
  if ((err = snd_pcm_hw_params_set_access (playback_handle, hw_params, SND_PCM_ACCESS_RW_INTERLEAVED)) < 0) {
    fprintf (stderr, "cannot set access type (%s)\n",
             snd_strerror (err));
    exit (1);
  }
	
  if ((err = snd_pcm_hw_params_set_format (playback_handle, hw_params, SND_PCM_FORMAT_S16_LE)) < 0) {
    fprintf (stderr, "cannot set sample format (%s)\n",
             snd_strerror (err));
    exit (1);
  }
	
  if ((err = snd_pcm_hw_params_set_rate (playback_handle, hw_params, 44100, 0)) < 0) {
    fprintf (stderr, "cannot set sample rate (%s)\n",
             snd_strerror (err));
    exit (1);
  }
	
  if ((err = snd_pcm_hw_params_set_channels (playback_handle, hw_params, 2)) < 0) {
    fprintf (stderr, "cannot set channel count (%s)\n",
             snd_strerror (err));
    exit (1);
  }
	
  if ((err = snd_pcm_hw_params (playback_handle, hw_params)) < 0) {
    fprintf (stderr, "cannot set parameters (%s)\n",
             snd_strerror (err));
    exit (1);
  }
	
  snd_pcm_hw_params_free (hw_params);

  if ((err = snd_pcm_prepare (playback_handle)) < 0) {
    fprintf (stderr, "cannot prepare audio interface for use (%s)\n",
             snd_strerror (err));
    exit (1);
  }

  snd_async_handler_t *async_handler;

  if ((err = snd_async_add_pcm_handler(&async_handler, playback_handle, playback_callback, buf)) < 0) {
    fprintf (stderr, "cannot add async handler (%s)\n",
             snd_strerror (err));
    exit (1);
  }

  if ((err = snd_pcm_start (playback_handle)) < 0) {
    fprintf (stderr, "cannot start audio interface for use (%s)\n",
             snd_strerror (err));
    exit (1);
  }

  if ((err = snd_pcm_writei (playback_handle, buf, 1024)) != 1024) {
    fprintf (stderr, "write to audio interface failed (%s)\n",
             snd_strerror (err));
    exit (1);
  }

	while (1) {
		sleep(1);
	}
}
