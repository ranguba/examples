# -*- ruby -*-

Rake::Task['db:test:prepare'].clear

base_path = "#{File.dirname(__FILE__)}/../../../.."
active_groonga_lib_path = "#{base_path}/activegroonga/lib"
$LOAD_PATH.unshift(File.expand_path(active_groonga_lib_path))

require 'active_groonga/tasks'
