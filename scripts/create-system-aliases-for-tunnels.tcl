#!
#-------------------------------------------------------------------
##
###Find VPNs and create an Alias Command for Each Tunnel
##
##
##History:
#     20210218 - Initially created so I can tab-complete my common VPN commands. - jhilving@fortinet.com
#
#-------------------------------------------------------------------

#-------------------------------------------------------------------
##Setup Script Variables. Change these to meet your needs.
#   RUNFLAG --> Flag to indicate you want commands printed AND executed. [no|yes]
#   VDOM    --> If in VDOM mode what VDOM should we focus? 
#----------------

set RUNFLAG "no"

######################
##Procs
#
proc do_cmd {cmd} { 
  return [ exec "$cmd\n" "# " 15 ]
}

proc print_runflag {} {
  global RUNFLAG
  puts "#RUNFLAG=$RUNFLAG"
  if { $RUNFLAG eq "yes"} {
    puts "  #Changes being made."
  } else {
    puts "  #No Changes being made."
  }
}

proc get_vdom_mode {} {
  set res [ do_cmd "get sys status | grep \"Virtual domain configuration\""]
  set vdom "unknown"
  if {[regexp {Virtual domain configuration: (\S+)} $res junk mode ]} {
    set vdom $mode
  }
  return $vdom
}

proc get_aliases {} {
  global aliases
  set res [ do_cmd "get sys alias | grep name" ]
  #set res "FG1 # get sys alias | grep name
  #name: vpn-summary   
  #name: routing-default   
  #name: routing-all   
  #name: routing-connected   
  #name: routing-static   
  #name: ip-arp   
  #name: ip-ints   
  #name: sys-version   
  #name: sys-license   
  #name: sys-sn   
  #name: sys-perf-status   
  #name: sys-perf-fw-stats   
  #name: sys-uptime   
  #name: vpn-clear-stats-mesh1-1   
  #name: vpn-tunnel-mesh2-1-details   
  #name: vpn-tunnel-mesh2-1-up   
  #name: vpn-tunnel-mesh2-1-down   
  #name: vpn-tunnel-mesh2-1-ikegw   
  #name: vpn-tunnel-mesh2-1-clear-stats   
  #name: vpn-tunnel-mesh1-1-details   
  #name: vpn-tunnel-mesh1-1-up   
  #name: vpn-tunnel-mesh1-1-down   
  #name: vpn-tunnel-mesh1-1-ikegw   
  #name: vpn-tunnel-mesh1-1-clear-stats"
  set out [split $res "\n"]
  foreach o $out {
    if {[regexp {^name: (tunnel-\S+)} $o junk a ]} {
      lappend aliases $a
    }
  }
  #return $aliases
}

proc get_vpns {} {
  global vpns
  set res [ do_cmd "get vpn ipsec tunnel summary" ]
  #set res "FG1 # get vpn ipsec tunnel summary 
  #'mesh2-1' 100.100.104.2:0  selectors(total,up): 1/1  rx(pkt,err): 1145/0  tx(pkt,err): 1672/0
  #'mesh1-1' 100.100.103.2:0  selectors(total,up): 1/0  rx(pkt,err): 0/0  tx(pkt,err): 0/5"
  set out [split $res "\n"]
  foreach o $out {
    if {[regexp {^\'(\S+)\' } $o junk v ]} {
      lappend vpns $v
    }
  }
  #return $vpns
}

proc remove_aliases {alist} {
  global RUNFLAG
  puts "config system alias"
  foreach a $alist {
    puts "  delete $a"
  }
  puts "end"
  if { $RUNFLAG eq "yes"} { 
    do_cmd "config system alias"
    foreach a $alist {
      do_cmd "delete $a"
    }
    do_cmd "end"
  }
}

proc add_aliases {vlist} {
  global RUNFLAG
  puts "config system alias"
  foreach a $vlist {
    puts "  edit tunnel-details-$a"
    puts "    set command \"get vpn ipsec tunnel name $a\""
    puts "  next"
    puts "  edit tunnel-up-$a"
    puts "    set command \"exec vpn ipsec tunnel up ${a}_0\""
    puts "  next"
    puts "  edit tunnel-down-$a"
    puts "    set command \"exec vpn ipsec tunnel down ${a}_0\""
    puts "  next"
    puts "  edit tunnel-ikegw-$a"
    puts "    set command \"get vpn ike gateway $a\""
    puts "  next"
    puts "  edit tunnel-clear-stats-$a"
    puts "    set command \"diagnose vpn tunnel stat flush $a\""
    puts "  next"
  }
  puts "end"
  if { $RUNFLAG eq "yes"} { 
    do_cmd "config system alias"
    foreach a $vlist {
      do_cmd "edit tunnel-details-$a"
      do_cmd "set command \"get vpn ipsec tunnel name $a\""
      do_cmd "next"
      do_cmd "edit tunnel-up-$a"
      do_cmd "set command \"exec vpn ipsec tunnel up ${a}_0\""
      do_cmd "next"
      do_cmd "edit tunnel-down-$a"
      do_cmd "set command \"exec vpn ipsec tunnel down ${a}_0\""
      do_cmd "next"
      do_cmd "edit tunnel-ikegw-$a"
      do_cmd "set command \"get vpn ike gateway $a\""
      do_cmd "next"
      do_cmd "edit tunnel-clear-stats-$a"
      do_cmd "set command \"diagnose vpn tunnel stat flush $a\""
      do_cmd "next"
    }
    puts "end"
  }
}

#Main
global aliases
global vpns
puts "#Starting Create VPN Alias Script. Purges VPN Aliases that may be old."
print_runflag
puts "####################################"

if {[ get_vdom_mode ] ne "disable"} { 
 do_cmd "config global"
}

get_aliases
get_vpns

if {[info exists aliases]} {
  remove_aliases $aliases
} 
if {[info exists vpns]} {
  add_aliases $vpns
} 

puts "#Script Done"