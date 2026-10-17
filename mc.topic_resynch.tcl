##
# Topic Resynch v2.1
#  by MC_8 - Carl M. Gregory <mc8@purehype.net>
#  This script will only run on eggdrop 1.5.5 or greater.
#
#    R.I.P. Mom, To always be remembered; Nancy Marie Gregory.
#
# My Website - http://mc.purehype.net:81/
# Have a bug?  http://mc.purehype.net:81/bugzilla/
##

##
# This script keeps the topic synched.  Helps avoid topics getting lost in
# net-split/join's.  On servers such as Undernet, a topic can easly be lost on 1
# server and not another -- you would resolve such a situation by just setting
# the topic again (resynch the topic).
##

##
# Commands (dcc)
##
# topic_info [channel]
#   This will display the currently channel topic, the topic stored in the
#   database, the person that set the topic that's in the database and how long
#   ago it was set in the database.
#
# chanset <#channel> <+/->mc.topic_resynch
#   This will enable (+) or disable (-) the script for the specified channel.
#   EXAMPLES:
#     chanset #abc123 +mc.topic_resynch
#       The script is now working for #abc123
#     chanset #eggdrop -mc.topic_resynch
#       The script is will no longer work for #eggdrop.
##

##
# Settings
##
#

# This script will need to save information about each channels' topic.  Where
# would you like the script to save that data?
set mc_tr(datafile) "./.mc.topic_resynch.data"

# How long, in minutes, would you like this script to wait before resetting the
# topic?  Unlike the older version of this script, this script deals with this
# in a smarter way.  Much like the X cservice bot for Undernet, this script will
# not reset the topic untill there has been some sort of activity on the
# channel.  I define activiety in this situation as being a join and/or quit
# (netsplit's included).  Example:
#   Lets say you set this to 60 minutes.  After 60 minutes, if the bot hasn't
#   seen channel activity within that time, the bot will wait for activity
#   before resetting the topic.
# This is considered to be smart, after all, there is no reason to reset the
# topic on a dead channel.  Logically, a dead channel (IE, no activity) cannot
# possibly of had the topic lost.
set mc_tr(wait) 60

# The bot will keep a record of the last topic set, just inscase it join's to
# find no topic set then it will set it to what it remembers it was last.  But,
# in some case there were never any topics and there is no topic now.  What do
# you want the bot to set the topic to in that case?  Leave this to "" to have
# it just ignore that channel untill a topic has been set.
set mc_tr(null_topic) "-- No topic, please set. --"

# If your server blocks topic changes that are identical; set this to what you
# want the topic temperarly set to, otherwise set this to "".  I know undernet
# now does blocking such as this.
set mc_tr(irc_topic_block) "Resynching ..."


## SVS Client (Script Version Service) v3.1.1 ##
# Once a day, the SVS Client will connect to MC_8's SVS Server to determine if
# there is a newer version of this script available.  This will only notify
# users of the new version via a note.  It's up to the owner of the bot to
# download, adjust settings then install the script.

# If a newer version is found, whom do you want to notify?  The notification is
# sent via a note.  Seperate each user with a space, or set this to "" to
# disable SVS notification.  For those whom know TCL; do not put this in list
# format, keep it in string format.
set mc_tr(svs:notify) "MC_8"

# Would you like to restrict the concept of a new version to stable releases
# only?
#   0 = No, inform of both stable and beta release versions.
#   1 = Yes, inform of only stable release versions.
set mc_tr(svs:mode) 0


#
##

##
# Done with configurations, do not edit past here unless you know TCL.
##
#

#Script:mc_tr

set mc_tr(script)      "Topic Resynch"
set mc_tr(version)     "v2.1"
set mc_tr(svs:script)  "topicresynch"
set mc_tr(svs:version) "002001000000"
set mc_tr(svs:server)  "mc.svs.purehype.net"
set mc_tr(svs:port)    "81"
set mc_tr(svs:get)     "/index.tcl"
set mc_tr(svs:query)   \
  "svs=$mc_tr(svs:script)&version=$mc_tr(svs:version)"

catch {unset temp}
if {![info exists numversion] || ($numversion < "1050500")} {
  set temp(tag) "$mc_tr(script) $mc_tr(version)"
  putlog "$temp(tag) by MC_8 will only work on eggdrop 1.5.5 or greater."
  putlog "$temp(tag)  will not work with eggdrop $version."
  putlog "$temp(tag)  not loaded."
  return 1
}


setudef flag mc.topic_resynch

# (start) Ensure the settings are always valid.
if {![info exists mc_tr(datafile)] || ($mc_tr(datafile) == "")} {
  set mc_tr(datafile) "./.mc.topic_resynch.data"
}
if {![info exists mc_tr(wait)] || [regexp -- {[^0-9]} $mc_tr(wait)] ||
    ($mc_tr(wait) <= 0)} {set mc_tr(wait) 60}
if {![info exists mc_tr(null_topic)]} {
  set mc_tr(null_topic) "-- No topic, please set. --"
}
if {![info exists mc_tr(irc_topic_block)]} {
  set mc_tr(irc_topic_block) ""
}

foreach {an op} [list datafile w wait w datafile u wait u null_topic u] {
  set continue 0
  foreach trace [trace vinfo mc_tr($an)] {
    if {([lindex $trace 0] == $op) && ([lindex $trace 1] == "mc:tr:trace")} {
      set continue 1
      break
    }
  }
  if {$continue} {continue}
  trace variable mc_tr($an) $op mc:tr:trace
}

# (stop) Ensure the settings are always valid.

# Error system, v3.0
proc mc:tr:error {command error arg} {
  global mc_tr version lastbind errorInfo
  putlog "Error in script $mc_tr(script) $mc_tr(version)."
  putlog "    Error System: v3.0"
  putlog "       Last Bind: [expr {[info exists lastbind]?$lastbind:"-NULL-"}]"
  putlog "         Command: $command"
  putlog "       Arguments: $arg"
  putlog "       Error Msg: $error"
  putlog "    Egg. Version: [expr {[info exists version]?$version:"-NULL-"}]"
  putlog "     TCL Version: [info tclversion]"
  putlog "  TCL Patchlevel: [info patchlevel]"
  putlog "*** Please submit this bug so MC_8 can fix it.  Visit"
  putlog "*** http://mc.purehype.net:81/bugzilla/ to properly report the bug."
  putlog \
    "*** Please include ALL info. in the bug report, including the next(s)."
  error $errorInfo
}

proc mc:tr:errchk {command arg} {
  if {![catch {eval $command $arg} return]} {return $return}
  mc:tr:error $command $return $arg
  return 0
}
# ^

proc mc:tr:trace {var_name array_name operation} {
  return [mc:tr:errchk mc:tr:trace_ [list $var_name $array_name $operation]]
}
proc mc:tr:trace_ {var_name array_name operation} {
  global mc_tr
  switch -- $operation {
    w {
      if {[regexp -- {^:active:(.*)$} $array_name dummy channel]} {
        mc:tr:list unset_active $channel
        if {[mc:tr:chanflag $channel mc.topic_resynch]} {
          mc:tr:list reset $channel
        }
        timer $mc_tr(wait) [list mc:tr:list timer $channel]
      } elseif {$array_name == "datafile"} {
        if {$mc_tr(datafile) == ""} {
          set mc_tr(datafile) "./.mc.topic_resynch.data"
        }
        mc:tr:list save -quiet
      } elseif {$array_name == "wait"} {
        if {[regexp -- {[^0-9]} $mc_tr(wait)] || ($mc_tr(wait) <= 0)} {
          set mc_tr(wait) 60
        }
        foreach channel [channels] {mc:tr:list timer $channel}
      }
    }
    u {
      switch -- $array_name {
        datafile {set mc_tr(datafile) "./.mc.topic_resynch.data"}
        wait {set mc_tr(wait) 60}
        null_topic {set mc_tr(null_topic) "-- No topic, please set. --"}
      }
    }
  }
}

bind topc - * mc:tr:topic
proc mc:tr:topic {nick uhost hand chan topic} {
  return [mc:tr:errchk mc:tr:topic_ [list $nick $uhost $hand $chan $topic]]
}
proc mc:tr:topic_ {nick uhost hand chan topic} {
  global mc_tr
  if {[isbotnick $nick] || ($topic == "")} {return 0}
  mc:tr:list set [list $chan $topic $nick $hand]
  mc:tr:list reset_timer $chan
}

bind raw - 331 mc:tr:raw
bind raw - 332 mc:tr:raw
bind raw - 333 mc:tr:raw
proc mc:tr:raw {from keyword arg} {
  return [mc:tr:errchk mc:tr:raw_ [list $from $keyword $arg]]
}
proc mc:tr:raw_ {from keyword arg} {
  global mc_tr
  set arg [split $arg]
  switch -- $keyword {
    331 {
      # telnet #abc123 :No topic is set.
      set channel [lindex $arg 1]
      if {![mc:tr:chanflag $channel mc.topic_resynch]} {return 0}
      mc:tr:list reset $channel
    }
    332 {
      # telnet #abc123 :http://www.web-eleets.com/Mom/  --MC_8, Carl M. Gregory
      set channel [lindex $arg 1]
      if {![mc:tr:chanflag $channel mc.topic_resynch]} {return 0}
      regexp -- {^:?(.*)$} [join [lrange $arg 2 end]] dummy topic
      set topic [string trim $topic]
      if {$topic == ""} {
        mc:tr:list reset $channel
        return 0
      }
      if {[lindex [mc:tr:list get $channel] 0] == $topic} {return 0}
      mc:tr:list set [list $channel $topic n/a n/a]
    }
    333 {
      # telnet #abc123 Type_O_- 1026751612
      set channel [lindex $arg 1]
      if {![mc:tr:chanflag $channel mc.topic_resynch]} {
        return 0
      }
      set temp(info) [mc:tr:list get $channel]
      set temp(time) [lindex $temp(info) 3]
      if {($temp(time) == "") || ([expr $temp(time)+5] < [clock seconds])} {
        return 0
      }
      set nick [lindex $arg 2]
      set time [lindex $arg 3]
      mc:tr:list set [list $channel [lindex $temp(info) 0] $nick n/a $time]
    }
  }; return 0
}

bind dcc - topic_info mc:tr:dcc:topic_info
proc mc:tr:dcc:topic_info {hand idx arg} {
  return [mc:tr:errchk mc:tr:dcc:topic_info_ [list $hand $idx $arg]]
}
proc mc:tr:dcc:topic_info_ {hand idx arg} {
  global mc_tr
  if {$arg != ""} {
    if {![validchan $arg]} {
      putdcc $idx "Invalid channel: $arg"
      return 0
    }
    set temp(channels) $arg
  } else {
    set temp(channels) [channels]
  }
  set temp(length) 1
  foreach channel $temp(channels) {
    if {[string length $channel] > $temp(length)} {
      set temp(length) [string length $channel]
    }
  }
  for {set index 0} {[set channel [lindex $temp(channels) $index]] != ""} {
    incr index
  } {
    if {[botonchan $channel]} {
      set irc_topic [topic $channel]
    } else {
      set irc_topic "Unknown, bot isn't on channel."
    }
    if {![mc:tr:chanflag $channel mc.topic_resynch]} {
      set db_topic "None, script disabled for channel."
      set db_nick "n/a"
      set db_hand "n/a"
      set db_duration "n/a"
    } else {
      set temp(info) [mc:tr:list get $channel]
      if {[set db_topic [lindex $temp(info) 0]] == ""} {
        if {$irc_topic == ""} {
          set db_topic $mc_tr(null_topic)
        } else {
          set db_topic $irc_topic
        }
      }
      set db_nick [lindex $temp(info) 1]
      set db_hand [lindex $temp(info) 2]
      set db_duration [duration [expr [clock seconds]-[lindex $temp(info) 3]]]
    }
    putdcc $idx [format "%$temp(length)s ---------------" $channel]
    putdcc $idx [format "%$temp(length)s IRC Topic     : %s" "" $irc_topic]
    putdcc $idx [format "%$temp(length)s Database Topic: %s" "" $db_topic]
    putdcc $idx [format "%$temp(length)s   |- Set by   : %s (hand: %s)" "" \
      $db_nick $db_hand]
    putdcc $idx [format "%$temp(length)s   `- Time set : %s ago" "" \
      $db_duration]
    if {[lindex $temp(channels) [expr $index+1]] != ""} {putdcc $idx ""}
  }; return 1
}

bind join - * mc:tr:activity
bind sign - * mc:tr:activity
bind splt - * mc:tr:activity
bind rejn - * mc:tr:activity
proc mc:tr:activity {nick uhost handle channel {reason ""}} {
  return [mc:tr:errchk mc:tr:activity_ \
    [list $nick $uhost $handle $channel $reason]]
}
proc mc:tr:activity_ {nick uhost handle channel reason} {
  mc:tr:list set_active $channel
}

bind evnt - save mc:tr:evnt
proc mc:tr:evnt {type} {
  return [mc:tr:errchk mc:tr:evnt_ [list $type]]
}
proc mc:tr:evnt_ {type} {mc:tr:list save}

proc mc:tr:list {command {arg ""}} {
  return [mc:tr:errchk mc:tr:list_ [list $command $arg]]
}
proc mc:tr:list_ {command arg} {
  global mc_tr botnick botnet-nick
  set array_name ":list:"
  switch -- $command {
    reset_timer {
      # mc:tr:list reset_timer <channel>
      set channel [string tolower $arg]
      foreach timer [timers] {
        if {[lindex $timer 1] == [list mc:tr:list timer $channel]} {
          killtimer [lindex $timer 2]
          break
        }
      }
      timer $mc_tr(wait) [list mc:tr:list timer $channel]
      return 1
    }
    timer {
      # mc:tr:list timer <channel>
      set channel [string tolower $arg]
      set temp(timer_set) 0
      foreach timer [timers] {
        if {[lindex $timer 1] == [list mc:tr:list timer $channel]} {
          if {[lindex $timer 0] > $mc_tr(wait)} {
            killtimer [lindex $timer 1]
            break
          } else {
            set temp(timer_set) 1
            break
          }
        }
      }
      if {$temp(timer_set)} {return 0}
      if {![mc:tr:chanflag $channel mc.topic_resynch]} {
        timer $mc_tr(wait) [list mc:tr:list timer $channel]
        return 0
      }
      if {![mc:tr:list get_active $channel]} {
        trace variable mc_tr(:active:$channel) w mc:tr:trace
        return 2
      } else {
        mc:tr:list unset_active $channel
        mc:tr:list reset $channel
        timer $mc_tr(wait) [list mc:tr:list timer $channel]
        return 1
      }
    }
    set_active {
      # mc:tr:list set_active <channel>
      set channel $arg
      if {![mc:tr:chanflag $channel mc.topic_resynch]} {return 0}
      set mc_tr(:active:[string tolower $channel]) 1
      return 1
    }
    unset_active {
      # mc:tr:list unset_active <channel>
      set channel $arg
      return [catch {unset mc_tr(:active:[string tolower $channel])}]
    }
    get_active {
      # mc:tr:list get_active <channel>
      set channel $arg
      if {![mc:tr:chanflag $channel mc.topic_resynch]} {return 0}
      if {![info exists mc_tr(:active:[string tolower $channel])]} {
        return 0
      } else {
        return 1
      }
    }
    reset {
      # mc:tr:list reset <channel>
      set channel $arg
      if {![mc:tr:chanflag $channel mc.topic_resynch]} {return 0}
      set temp(irc:topic) [string trim [topic $channel]]
      set temp(db:topic) [string trim [lindex [mc:tr:list get $channel] 0]]
      if {$mc_tr(irc_topic_block) != ""} {
        putserv "TOPIC $channel :$mc_tr(irc_topic_block)"
      }
      if {$temp(irc:topic) == ""} {
        if {$temp(db:topic) == ""} {
          if {$mc_tr(null_topic) != ""} {
            putserv "TOPIC $channel :$mc_tr(null_topic)"
            mc:tr:list set \
              [list $channel $mc_tr(null_topic) $botnick ${botnet-nick}]
          }
        } else {
          putserv "TOPIC $channel :$temp(db:topic)"
        }
      } else {
        # Topic exists, let's gather information about it.
        if {$temp(irc:topic) != $temp(db:topic)} {
          mc:tr:list set [list $channel $temp(irc:topic) n/a n/a]
          putserv "TOPIC $channel"
        }; putserv "TOPIC $channel :$temp(irc:topic)"
      }; return 1
    }
    set {
      # mc:tr:list set [list <channel> <topic> <nick> <handle> [timestamp]]
      #
      # In memory, mc_tr(:list:<lchannel>) "<topic> <nick> <handle> <timestamp>"
      #   ^^ Valid list format.
      set channel [lindex $arg 0]
      if {![validchan $channel] ||
          ![mc:tr:chanflag $channel mc.topic_resynch]} {return 0}
      set topic [lindex $arg 1]
      set nick [lindex $arg 2]
      set hand [lindex $arg 3]
      if {[set time [lindex $arg 4]] == ""} {set time [clock seconds]}
      append array_name [string tolower $channel]
      set mc_tr($array_name) [list $topic $nick $hand $time]
      return 1
    }
    get {
      # mc:tr:list get <channel>
      #
      # return: <topic> <nick> <handle> <timestamp>
      #     or: ""
      return [lindex [array get mc_tr ${array_name}[string tolower $arg]] 1]
    }
    load {
      # mc:tr:list load
      if {![file exists $mc_tr(datafile)]} {
        close [open $mc_tr(datafile) w]
        return 1
      }
      set io [open $mc_tr(datafile) r]
      set line_number 0
      if {[info tclversion] >= "8.3"} {
        set temp(re_syntax) {^  #!(v.*?),(.*?),(.*?) *$}
      } else {
        set temp(re_syntax) {^  #!(v.[^,]*),([^,]*),([^,]*) *$}
      }
      set version v1.0
      set bot ""
      set time_saved 0
      while {![eof $io]} {
        incr line_number
        gets $io line
        if {([string trim $line] == "") || (($line_number == "1") &&
            [regexp -- $temp(re_syntax) $line dummy version bot time_saved])} {
          continue
        }
        switch -- $version {
          v1.0 {
            # Version 1.0 line syntax: -<channel>- <topic>
            # -<channel>- in string format, <topic> list.
            mc:tr:list set [list [lindex [split $line] 0] [lindex $line end] \
              n/a n/a]
          }
          v2.0 {
            # Version 2.0 line syntax:
            #   <channel> <topic> <nick> <handle> <clock seconds>
            # Total list format.
            mc:tr:list set $line
          }
        }
      }
      close $io
      return 1
    }
    save {
      # mc:tr:list save [-quiet]
      #
      # Version 2.0 line syntax:
      #   <channel> <topic> <nick> <handle> <clock seconds>
      # Total list format.
      if {[lindex $arg 0] != "-quiet"} {
        putlog "Writing $mc_tr(script) file..."
      }
      global botnet-nick
      set io [open $mc_tr(datafile) w]
      puts $io "  #!v2.0,${botnet-nick},[clock seconds]"
      foreach {array value} [array get mc_tr :list:*] {
        regexp -- {^:list:(.*)$} $array dummy channel
        if {![validchan $channel] ||
            ![mc:tr:chanflag $channel mc.topic_resynch]} {continue}
        puts $io "[list $channel] $value"
      }
      close $io
      return 1
    }
  }
}


## More Tools quick procs.
## -- http://mc.purehype.net:81/script_info.tcl?script=moretools

# badargs <args> <min_llength> <max_llength|end> <argNames>
#     version:
#       v1.0
proc mc:tr:badargs {{args ""}} {
  if {[llength $args] < 4} {
    error {
   wrong # args: should be "mc:tr:badargs args min_llength max_llength argNames"
    }
  }

  set index 0
  foreach varName [list args min max names] {
    set check_$varName [lindex $args $index]
    incr index
  }

  if {[regexp -- {([^0-9])} $check_min -> bad]} {
    error "bad number \"$bad\" in: $check_min"
  }
  if {[regexp -- {([^0-9])} $check_max -> bad] && ($check_max != "end")} {
    error "bad number \"$bad\" in: $check_max"
  }

  # Make sure $check_args is in list format, if not then make it so.
  # Were not going to use 2list here, don't want to evoke a 'too many nested
  # calls to Tcl_EvalObj' error since '2list' uses on this proc.
  if {[catch {llength $check_args} llength]} {
    set check_args [split $check_args]
    set llength $check_args
  }

  if {($llength < $check_min) || (($llength != "end") &&
      ($llength > $check_max))} {
    if {[info level] == "1"} {return 1}
    error "wrong # args: should be \"[lindex [info level -1] 0] $check_names\""
  }; return 0
}

# unlist <argsList> [varName1] [varName2] ... [varNameN]
#     version:
#       v1.0
proc mc:tr:unlist {{args ""}} {
  mc:tr:badargs $args 1 end "argsList ?varName varName ...?"
  set argList [lindex $args 0]
  set argList [expr {([catch {llength $argList}])?[split $argList]:$argList}]
  set argNames [lrange $args 1 end]
  if {![llength $argNames]} {
    return [expr {(![catch {llength $argList}])?
      [join $argList]:$argList}]
  }
  for {set index 0} {$index < [llength $argNames]} {incr index 1} {
    set argName     [lindex $argNames $index]
    set argListItem [lindex $argList  $index]

    set argName_ [expr {([catch {llength $argName}])?[split $argName]:$argName}]
    set setTo   [lindex $argName_ 1]
    set argName [lindex $argName_ 0]

    if {$argName == ""} {continue}

    upvar 1 $argName var

    if {[expr $index+1] > [llength $argList]} {
      if {[llength $argName_] == "2"} {set var $setTo}
    } else {
      if {$argName == "args"} {
        set var [lrange $argList $index end]
        incr index [expr [llength $var]-1]
      } else {set var $argListItem}
    }
  }; return $index
}

# chanflag <channel> <flag>
#     version:
#       v3.1
proc mc:tr:chanflag {{args ""}} {
  mc:tr:badargs $args 2 2 "channel flag"
  mc:tr:unlist $args channel flag

  if {![validchan $channel]} {error "no such channel record"}

  # Try the 'channel' commands' 'get' option first, it's faster since it is
  # written in C by the eggdrop development team.
  if {![catch {channel get $channel $flag} output]} {return $output}

  set temp(chaninfo) [string tolower [channel info $channel]]
  if {[lsearch -exact $temp(chaninfo) +[string tolower $flag]] >= "0"} {
    return 1
  }; return 0
}

## End of More Tools quick procs.


# Load datafile.
mc:tr:list load

# Start the timers.
foreach channel [channels] {mc:tr:list timer $channel}


## SVS v3.1.1
set mc_tr(svs:client_version) "v3.1.1"
if {![info exists mc_tr(svs:mode)] ||
    ![regexp -- {^(1|0)$} $mc_tr(svs:mode)]} {
  set mc_tr(svs:mode) 0
}
if {![info exists mc_tr(svs:notify)]} {
  if {![info exists owner]} {set owner ""}
  set mc_tr(svs:notify) $owner
}

bind time - "00 00 *" mc:tr:do_svs
proc mc:tr:do_svs {{args ""}} {
  global mc_tr
  mc:tr:do_svs_ $mc_tr(svs:server) $mc_tr(svs:port) $mc_tr(svs:get)
}

proc mc:tr:do_svs_ {svs_server svs_port svs_get} {
  global mc_tr tcl_platform
  if {[catch {
          socket -async $svs_server $svs_port
             } sid]} {
    putloglev d * "$mc_tr(script): SVS socket error: $sid"
    return 1
  }

  # This block of code is to get a standard User-Agent line of information, as
  # proposed in http://www.mozilla.org/build/revised-user-agent-strings.html
  foreach array_name [list platform os osVersion machine] {
    set temp($array_name) [lindex [array get tcl_platform $array_name] 1]
  }
  switch -- $temp(platform) {
    windows {
      switch -- $temp(os) {
        Windows {set temp(2) Win$temp(osVersion)}
        "Windows 95" {
          if {$temp(osVersion) < "4.10"} {
            set temp(2) Win95
          } else {
            set temp(2) Win98
          }
        }
        "Windows 98" {set temp(2) Win98}
        "Windows NT" {
          if {$temp(osVersion) >= "5.0"} {
            set temp(2) "Windows NT $temp(osVersion)"
          } else {
            set temp(2) WinNT$temp(osVersion)
          }
        }
        default {
          set temp(2) "$temp(os) $temp(osVersion)"
        }
      }
    }
    unix {
      set temp(2) "unix $temp(machine)"
    }
    macintosh {
      set temp(2) $temp(machine)
    }
    default {
      set temp(2) "$temp(os) $temp(osVersion) $temp(machine)"
    }
  }
  set temp(user_agent) "Mozilla/5.001 ($temp(platform); U; $temp(2); en) "
  append temp(user_agent) "Gecko/25250101 $mc_tr(svs:script)/"
  append temp(user_agent) "$mc_tr(svs:version) SVS_Client/"
  append temp(user_agent) "$mc_tr(svs:client_version)"
  # ^

  fconfigure $sid -blocking 0 -buffering line
  set tout \
    [after 60000 "mc:tr:svs_talk $sid timeout $svs_server $svs_port"]
  fileevent $sid readable "mc:tr:svs_talk $sid $tout"
  puts $sid "GET $svs_get?$mc_tr(svs:query) HTTP/1.0\
           \nHost: $svs_server:$svs_port\
           \nUser-Agent: $temp(user_agent)\n"
  flush $sid
}

proc mc:tr:svs_talk {sid tout {svs_server ""} {svs_port ""}} {
  global mc_tr
  set array [list svs temp $sid]
  if {$tout == "timeout"} {
    set temp(1) "$svs_server:$svs_port"
    putloglev d * \
      "$mc_tr(script): SVS Warning: Timed out connecting to $temp(1)."
    catch {unset mc_tr($array)}
    close $sid
    return 0
  }
  if {[eof $sid]} {
    catch {unset mc_tr($array)}
    close $sid
    return 1
  }
  gets $sid get
  after cancel $tout
  if {![info exist mc_tr($array)]} {
    if {$get == ""} {set mc_tr($array) 1}
    return -1
  }
  if {($get == "") || [catch {llength $get}]} {
    return -2
  }
  switch -- [lindex $get 0] {
    200 {
      set temp(host) [lindex $get 1]
      set temp(port) [lindex $get 2]
      set temp(get) [lindex $get 3]
      set temp(cache) "$temp(host) at $temp(port)"
      putloglev d * \
        "$mc_tr(script): SVS is being redirected to $temp(cache)."
      mc:tr:do_svs_ $temp(host) $temp(port) $temp(get)
      close $sid
      return 200
    }
    003 {
      set temp(reply) [lrange $get 1 end]
      for {set number 0} {$number <= 5} {incr number} {
        set temp(reply:$number) [lindex $temp(reply) $number]
      }
      if {$temp(reply:0) != $mc_tr(svs:script)} {
        set temp(1) "wanted $mc_tr(svs:script), got $temp(reply:0)"
        putloglev d * "$mc_tr(script): SVS Error: $temp(1)"
        unset mc_tr($array)
        close $sid
        return -3
      }
      if {$mc_tr(svs:mode)} {
        set temp(svs:version) [string range $mc_tr(svs:version) 0 8]999
      } else {
        set temp(svs:version) [string range $mc_tr(svs:version) 0 11]
      }
      if {$temp(reply:1) > $temp(svs:version)} {
        set temp(note) $temp(reply:5)
        regsub -all -- %0 $temp(note) $temp(reply:0) temp(note)
        regsub -all -- %1 $temp(note) $temp(reply:1) temp(note)
        regsub -all -- %2 $temp(note) $temp(reply:2) temp(note)
        regsub -all -- %3 $temp(note) $temp(reply:3) temp(note)
        regsub -all -- %4 $temp(note) $temp(reply:4) temp(note)
        regsub -all -- %version $temp(note) $mc_tr(version) temp(note)
        foreach temp(to) [split $mc_tr(svs:notify) ",; "] {
          if {[string trim $temp(to)] == ""} {continue}
          regsub -- %nick $temp(note) $temp(to) temp(note2)
          set temp(lunotes) [notes $temp(to) -[notes $temp(to)]]]
          if {[string match *$temp(note2)* $temp(lunotes)]} {
            set temp(found_note) 0
            foreach temp(unote) $temp(lunotes) {
              if {$temp(note2) == [lindex $temp(unote) 2]} {
                set temp(found_note) 1
                break
              }
            }
            if {$temp(found_note)} {continue}
          }
          set temp(error) "sending note to $temp(to) -> "
          switch -- [sendnote SVS $temp(to) $temp(note2)] {
            0 {
              if {![validuser $temp(to)]} {
                append temp(error) "invalid user"
              } else {append temp(error) "unknown error"}
              putloglev d * \
                "$mc_tr(script): SVS sendnote error: $temp(error)"
            }
            3 {
              append temp(error) "notebox too full"
              putloglev d * \
                "$mc_tr(script): SVS sendnote error: $temp(error)"
            }
          }
        }
      }
      unset mc_tr($array)
      close $sid
      return 2
    }
  }
}
## ^


putlog "$mc_tr(script) $mc_tr(version) by MC_8 loaded."

##
# History  ( <Fixed by> - [Found by] - <Info> )
##
# v2.1 (11.23.02)
#  MC_8 -          - Fixed 'can't read "channel": no such variable'.
#  MC_8 -          - Added `irc_topic_block` tcl variable to counteract TOPIC
#                    duplication blocking from the irc server.
#  MC_8 - Riccardo - Fixed regular expression problem with eggdrop's running
#                    with pre 8.3 versions of TCL.  Error would be something to
#                    the effect of `couldn't compile regular expression pattern:
#                    nested *?+`.  [bug: 185]
#  MC_8 -          - Added `badargs` tcl command.  none -> v1.0
#  MC_8 -          - Added `unlist` tcl command.  none -> v1.0
#  MC_8 -          - Upgraded `chanflag` tcl command.  v3.0 -> v3.1
#  MC_8 -          - Upgraded SVS client.  v3.0 -> v3.1.1
#  MC_8 -          - Upgraded Error Catch System.  v2.1 -> v3.0
#
# v2.0 (07.15.02)
#  MC_8 - - Added 'topic_info' dcc console command.
#  MC_8 - - Added Error Catching System.  none -> v2.1
#  MC_8 - - Added SVS Client.  none -> v3.0
#  MC_8 - - Rewrote all of the script's code.  Now does smart topic resetting.
#  MC_8 - - Changed setting name `topicres` to `wait`.
#  MC_8 - - Removed now unused `bold` and `filt` proc.
#  MC_8 - - Changed variable names from `himc` to `mc_tr`.  If your upgrading,
#           pleas do a full restart as to clear the memory of the old memory
#           settings (if you want to conserve on memory, not like it took allot
#           anyhow).
#  MC_8 - - Removed setting `channels`, new channel flag will take it's place.
#  MC_8 - - Added channel flag 'mc.topic_resynch'.
#  MC_8 - - Removed DCC console commands 'tr', 'trsave', 'trtopic' and
#           'trchannels'.  I see no need for them.  Especially things like
#           'trsave', I'm going to be putting in a timer to save once an hour
#           anyhow (in v2.0).
#
# v1.1 (05.30.00)
#  MC_8 - \-\iTman - This script actually took shape a long time ago, some time
#                    in the fall of 98`.  I got a stable build working and kinda
#                    forgot about it in my pile of mc.* scripts.  Anyhow, here
#                    it is.
##
