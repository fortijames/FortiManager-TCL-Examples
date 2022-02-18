#!

#
##Enviroments
#
set VDOM "root"

#
##Procs
#
proc do_cmd {cmd} { 
  return [ exec "$cmd\n" "# " 15 ]
}

proc get_vdom_mode {} {
  set res [ do_cmd "get sys status | grep \"Virtual domain configuration\""]
  set vdom "unknown"
  if {[regexp {Virtual domain configuration: (\S+)} $res junk mode ]} {
    set vdom $mode
  }
  return $vdom
}

#
##Main
#
if {[ get_vdom_mode ] ne "disable"} { 
  puts "#Entering VDOM $VDOM"
  #do_cmd "config vdom"
  #do_cmd "edit $VDOM"
} else {
  puts "#No VDOM Needed"
}