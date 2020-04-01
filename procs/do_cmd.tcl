######################
##Procs
#
proc do_cmd {cmd} {
  return [exec "$cmd\n" "# " 15]
}

######################
##Main Code
#
puts "#BEGIN: Running a command"
do_cmd "get system status"
puts "#END"

puts "#BEGIN: Running a command and printing the output:"
puts [do_cmd "get system status"]
puts "#END"

puts "#BEGIN: Running a command, saving the output, and then printing the output."
set status [do_cmd "get system status"]
puts $status
puts "#END"