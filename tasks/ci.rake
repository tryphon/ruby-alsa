desc "Run continuous integration tasks (spec, ...)"
task :ci => ["package:binary"]
