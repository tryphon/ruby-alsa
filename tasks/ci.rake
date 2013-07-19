desc "Run continuous integration tasks (spec, ...)"
task :ci => ["clean", "package:binary"]
