##
# Topic Resynch v2.2
#  by MC_8 - Carl M. Gregory <mc8@purehype.net>
#  This script will only run on eggdrop 1.6.14 or greater.
#
#    R.I.P. Mom, To always be remembered; Nancy Marie Gregory.
#
# My Website - http://mc.purehype.net/
# Have a bug?  http://mc.purehype.net/bugzilla/
##

##
# This script keeps the topic synched.  Helps avoid topics getting lost in
# net-split/join's.  On servers such as Undernet, a topic can easily be lost on
# 1 server and not another -- you would resolve such a situation by just setting
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
# chanset <channel> <+/->mc.topic_resynch
#   This will enable (+) or disable (-) the script for the specified channel.
#   EXAMPLES:
#     chanset #abc123 +mc.topic_resynch
#       The script is now working for #abc123
#     chanset #eggdrop -mc.topic_resynch
#       The script is will no longer work for #eggdrop.
##

##
# Configuration
##
#

# This script will need to save information about each channels' topic.  Where
# would you like the script to save that data?
set mc_tr(:config:datafile) "./.mc.topic_resynch.data"

# How long, in minutes, would you like this script to wait before resetting the
# topic?  Unlike the older version of this script, this script deals with this
# in a smarter way.  Much like the X cservice bot for Undernet, this script will
# not reset the topic until there has been some sort of activity on the
# channel.  I define activity in this situation as being a join and/or quit
# (netsplit's included).  Example:
#   Lets say you set this to 60 minutes.  After 60 minutes, if the bot hasn't
#   seen channel activity within that time, the bot will wait for activity
#   before resetting the topic.
# This is considered to be smart, after all, there is no reason to reset the
# topic on a dead channel.  Logically, a dead channel (IE, no activity) cannot
# possibly of had the topic lost.
set mc_tr(:config:wait) 60

# The bot will keep a record of the last topic set, just incase it join's to
# find no topic set then it will set it to what it remembers it was last.  But,
# in some case there were never any topics and there is no topic now.  What do
# you want the bot to set the topic to in that case?  Leave this to "" to have
# it just ignore that channel until a topic has been set.
set mc_tr(:config:null_topic) "-- No topic, please set. --"

# If your server blocks topic changes that are identical; set this to what you
# want the topic temporarily set to, otherwise set this to "".  I know Undernet
# now does blocking such as this.
set mc_tr(:config:irc_topic_block) "Resynching ..."

## SVS Client (Script Version Service) v4.0.4 ##
# Once a day, the SVS Client will connect to MC_8's SVS Server to determine if
# there is a newer version of this script available.  If a newer version is
# found, the script will be auto updated.

# [0=no/1=yes] Do you want to enable auto updating?  If you chose to disable
# auto updating, it will not automatically update the script upon finding a
# newer version.
set mc_tr(:config:svs:enable) 1

#
##

##
# Done with configurations, do not edit past here unless you know TCL.
##
#

#Script:mc_tr

## SVS insert (pre code)
catch {unset temp}
set mc_tr(info:vars) ""
foreach {temp(name) temp(value)} [array get mc_tr :config:*] {
  lappend mc_tr(info:vars) [list $temp(name) $temp(value)]
}
set mc_tr(info:loc) [info script]
array set mc_tr [list \
  script                 "Topic Resynch" \
  version                "v2.2" \
  svs:script             "topicresynch" \
  svs:version            "002002000000" \
  svs:client_version     "v4.0.4" \
  svs:client_svs_version "004000004000" \
  svs:server             "mc.svs.purehype.net" \
  svs:port               "80" \
  svs:get                "/index.tcl"]
set mc_tr(svs:query)    "svs=$mc_tr(svs:script)&"
append mc_tr(svs:query) "version=$mc_tr(svs:version)&"
append mc_tr(svs:query) \
  "svs_version=$mc_tr(svs:client_svs_version)"

if {![info exists numversion] || 
    ([string range $numversion 0 4] < "10614") ||
    (([string range $numversion 0 4] == "10614") &&
     ([string range $numversion 5 6] != "00"))} {
  set temp(tag) "$mc_tr(script) $mc_tr(version)"
  putloglev o * \
    "$temp(tag) by MC_8 will only work on eggdrop 1.6.14 (stable) or greater."
  putloglev o * "$temp(tag) will not work with eggdrop $version."
  putloglev o * "$temp(tag) not loaded."
  return 1
}
## ^

# Error system, v3.2
proc mc:tr:errchk {command args} {
  if {![info exists ::lastCommand]} {set ::lastCommand [list]}
  set ::lastCommand \
    "[list [list [clock seconds] $command $args]] $::lastCommand"
  set ::lastCommand [lrange $::lastCommand 0 4]
  if {![catch {eval $command $args} return]} {return $return}
  if {$::errorCode != "mc.ecs.done"} {
    set temp(lastbind) [expr {[info exists ::lastbind]?$::lastbind:"-NULL-"}]
    set temp(eversion) [expr {[info exists ::version]?$::version:"-NULL-"}]
    putloglev o * "************************************"
    putloglev o * "(ECS 3.2) Error found in TCL script."
    putloglev o * "  --------------"
    putloglev o * "  Script name   : $::mc_tr(script)"
    putloglev o * "  Script version: $::mc_tr(version)"
    putloglev o * "  Egg. Version  : $temp(eversion)"
    putloglev o * "  TCL Version   : [info tclversion] ([info patchlevel])"
    putloglev o * "  --------------"
    putloglev o * "  Last Bind     : $temp(lastbind)"
    putloglev o * "  Last Commands :"
    foreach line $::lastCommand {
      foreach {time command arg} $line break
      putloglev o * "    ${time}- $command $arg"
    }
    putloglev o * "  Error stack   :"
    foreach line [split $::errorInfo \n] {
      putloglev o * "    $line"
    }
    putloglev o * "  --------------"
    putloglev o * "  Submit this bug to http://mc.purehype.net/bugzilla/ . If"
    putloglev o * "  you are experiencing problems with bugzilla, contact MC_8"
    putloglev o * "  via e-mail at mc8@purehype.net. Please include all"
    putloglev o * "  information shown here, in this ECS report."
    putloglev o * "************************************"
  }
  return -errorcode mc.ecs.done -code error
}
# ^

setudef flag mc.topic_resynch

if {![info exists mc_tr(:config:datafile)] ||
    ($mc_tr(:config:datafile) == "")} {
  set mc_tr(:config:datafile) "./.mc.topic_resynch.data"
}
if {![info exists mc_tr(:config:wait)] ||
    [regexp -- {[^0-9]} $mc_tr(:config:wait)] ||
    ($mc_tr(:config:wait) <= 0)} {
  set mc_tr(:config:wait) 60
}
if {![info exists mc_tr(:config:null_topic)]} {
  set mc_tr(:config:null_topic) "-- No topic, please set. --"
}
if {![info exists mc_tr(:config:irc_topic_block)]} {
  set mc_tr(:config:irc_topic_block) ""
}

foreach {an op} [list :config:datafile w :config:wait w :config:datafile u \
  :config:wait u :config:null_topic u] {
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

proc mc:tr:trace {var_name array_name operation} {
  return [mc:tr:errchk mc:tr:trace_ $var_name $array_name $operation]
}
proc mc:tr:trace_ {var_name array_name operation} {
  global mc_tr
  switch -- $operation {
    w {
      if {[regexp -- {^:active:(.*)$} $array_name -> channel]} {
        mc:tr:list unset_active $channel
        if {[channel get $channel mc.topic_resynch]} {mc:tr:list reset $channel}
        timer $mc_tr(:config:wait) [list mc:tr:list timer $channel]
      } elseif {$array_name == ":config:datafile"} {
        if {$mc_tr(:config:datafile) == ""} {
          set mc_tr(:config:datafile) "./.mc.topic_resynch.data"
        }
        mc:tr:list save -quiet
      } elseif {$array_name == ":config:wait"} {
        if {[regexp -- {[^0-9]} $mc_tr(:config:wait)] ||
            ($mc_tr(:config:wait) <= 0)} {
          set mc_tr(:config:wait) 60
        }
        foreach channel [channels] {mc:tr:list timer $channel}
      }
    }
    u {
      switch -- $array_name {
        :config:datafile {
          set mc_tr(:config:datafile) "./.mc.topic_resynch.data"
        }
        :config:wait {
          set mc_tr(:config:wait) 60
        }
        :config:null_topic {
          set mc_tr(:config:null_topic) "-- No topic, please set. --"
        }
      }
    }
  }
}

bind topc - * mc:tr:topic
proc mc:tr:topic {nick uhost handle channel topic} {
  return [mc:tr:errchk mc:tr:topic_ $nick $uhost $handle $channel $topic]
}
proc mc:tr:topic_ {nick uhost handle channel topic} {
  if {[isbotnick $nick] || ($topic == "")} {return 0}
  mc:tr:list set [list $channel $topic $nick $handle]
  mc:tr:list reset_timer $channel
}

bind raw - 331 mc:tr:raw
bind raw - 332 mc:tr:raw
bind raw - 333 mc:tr:raw
proc mc:tr:raw {from keyword arg} {
  return [mc:tr:errchk mc:tr:raw_ $from $keyword $arg]
}
proc mc:tr:raw_ {from keyword arg} {
  global mc_tr
  set arg [split $arg]
  set to [lindex $arg 0]
  set channel [lindex $arg 1]
  if {![isbotnick $to] ||
      ![validchan $channel] ||
      ![channel get $channel mc.topic_resynch]} {return 0}
  
  switch -- $keyword {
    331 {
      mc:tr:list reset $channel
    }
    332 {
      if {[info exists mc_tr(:temp:ignore:333)]} {unset mc_tr(:temp:ignore:333)}
      regexp -- {^:?(.*)$} [join [lrange $arg 2 end]] -> topic
      set topic [string trim $topic]
      if {$topic == ""} {
        set mc_tr(:temp:ignore:333) 1
        mc:tr:list reset $channel
        return 0
      }
      if {[lindex [mc:tr:list get $channel] 0] == $topic} {return 0}
      mc:tr:list set [list $channel $topic n/a n/a]
    }
    333 {
      if {[info exists mc_tr(:temp:ignore:333)]} {
        unset mc_tr(:temp:ignore:333)
        return 0
      }
      set temp(info) [mc:tr:list get $channel]
      foreach {"" "" nick time} $arg break
      mc:tr:list set [list $channel [lindex $temp(info) 0] $nick n/a $time]
    }
  }; return 0
}

bind dcc - topic_info mc:tr:dcc:topic_info
proc mc:tr:dcc:topic_info {handle idx arg} {
  return [mc:tr:errchk mc:tr:dcc:topic_info_ $handle $idx $arg]
}
proc mc:tr:dcc:topic_info_ {handle idx arg} {
  global mc_tr
  set channel [lindex [split $arg] 0]
  if {$arg == ""} {set channels [channels]} \
  elseif {![validchan $channel]} {
    putdcc $idx "Invalid channel: $channel"
    return 0
  } else {set channels [list $channel]}
  
  set length 1
  foreach channel $channels {
    set length_ [string length $channel]
    if {$length_ > $length} {set length $length_}
  }
  
  for {set index 0} {[set channel [lindex $channels $index]] != ""} {
    incr index
  } {
    if {[botonchan $channel]} {set irc_topic [topic $channel]} \
    else {set irc_topic "Unknown, bot isn't on channel."}
    
    if {![channel get $channel mc.topic_resynch]} {
      set db_topic "None, script disabled for channel."
      set db_nick "n/a"
      set db_handle "n/a"
      set db_duration "n/a"
    } else {
      set info [mc:tr:list get $channel]
      if {$info == ""} {
        set db_topic $mc_tr(:config:null_topic)
        set db_nick n/a
        set db_handle n/a
        set db_time 0
      } else {
        foreach {db_topic db_nick db_handle db_time} $info break
        if {$db_topic == ""} {
          if {$irc_topic == ""} {set db_topic $mc_tr(:config:null_topic)} \
          else {set db_topic $irc_topic}
        }
      }
      set db_duration [duration [expr [clock seconds]-$db_time]]
    }
    
    putdcc $idx [format "%-${length}s ---------------" $channel]
    putdcc $idx [format "%+${length}s IRC Topic     : %s" "" $irc_topic]
    putdcc $idx [format "%+${length}s Database Topic: %s" "" $db_topic]
    putdcc $idx [format "%+${length}s   |- Set by   : %s (handle: %s)" "" \
      $db_nick $db_handle]
    putdcc $idx [format "%+${length}s   `- Time set : %s ago" "" \
      $db_duration]
    if {[lindex $channels [expr $index+1]] != ""} {putdcc $idx ""}
  }; return 1
}

bind join - * mc:tr:activity
bind sign - * mc:tr:activity
bind splt - * mc:tr:activity
bind rejn - * mc:tr:activity
proc mc:tr:activity {nick uhost handle channel {reason ""}} {
  return [mc:tr:errchk mc:tr:activity_ $nick $uhost $handle $channel $reason]
}
proc mc:tr:activity_ {nick uhost handle channel reason} {
  mc:tr:list set_active $channel
}

bind evnt - save mc:tr:evnt
proc mc:tr:evnt {type} {
  return [mc:tr:errchk mc:tr:evnt_ $type]
}
proc mc:tr:evnt_ {type} {mc:tr:list save}

proc mc:tr:list {command {arg ""}} {
  return [mc:tr:errchk mc:tr:list_ $command $arg]
}
proc mc:tr:list_ {command arg} {
  global mc_tr botnick botnet-nick
  
  set array_name ":list:"
  
  switch -- $command {
    
    "reset_timer" {
      # mc:tr:list reset_timer <channel>
      set channel [string tolower $arg]
      if {![validchan $channel]} {return 0}
      
      foreach timer [timers] {
        if {[lindex $timer 1] == [list mc:tr:list timer $channel]} {
          killtimer [lindex $timer 2]
          break
        }
      }
      timer $mc_tr(:config:wait) [list mc:tr:list timer $channel]
      return 1
    }
    
    "timer" {
      # mc:tr:list timer <channel>
      set channel [string tolower $arg]

      set timer_set 0      
      foreach timer [timers] {
        if {[lindex $timer 1] == [list mc:tr:list timer $channel]} {
          if {[lindex $timer 0] > $mc_tr(:config:wait)} {
            killtimer [lindex $timer 1]
            break
          } else {
            set timer_set 1
            break
          }
        }
      }
      if {$timer_set} {return 0}
      if {![validchan $channel] ||
          ![channel get $channel mc.topic_resynch]} {
        timer $mc_tr(:config:wait) [list mc:tr:list timer $channel]
        return 1
      }
      
      if {![mc:tr:list get_active $channel]} {
        trace variable mc_tr(:active:$channel) w mc:tr:trace
        return 2
      } else {
        mc:tr:list unset_active $channel
        mc:tr:list reset $channel
        timer $mc_tr(:config:wait) [list mc:tr:list timer $channel]
        return 3
      }
    }
    
    "set_active" {
      # mc:tr:list set_active <channel>
      set channel [string tolower $arg]
      if {![validchan $channel] ||
          ![channel get $channel mc.topic_resynch]} {return 0}
          
      set mc_tr(:active:$channel) 1
      return 1
    }
    
    "unset_active" {
      # mc:tr:list unset_active <channel>
      set channel [string tolower $arg]
      
      return [catch {unset mc_tr(:active:$channel)}]
    }
    
    "get_active" {
      # mc:tr:list get_active <channel>
      set channel [string tolower $arg]
      if {![validchan $channel] ||
          ![channel get $channel mc.topic_resynch]} {return 0}
          
      return [info exists mc_tr(:active:$channel)]
    }
    
    "reset" {
      # mc:tr:list reset <channel>
      set channel [string tolower $arg]
      if {![validchan $channel] ||
          ![channel get $channel mc.topic_resynch]} {return 0}
          
      set irc_topic [string trim [topic $channel]]
      set db_topic [string trim [lindex [mc:tr:list get $channel] 0]]
      
      if {$mc_tr(:config:irc_topic_block) != ""} {
        putserv "TOPIC $channel :$mc_tr(:config:irc_topic_block)"
      }
      
      if {$irc_topic == ""} {
        if {$db_topic == ""} {
          if {$mc_tr(:config:null_topic) != ""} {
            putserv "TOPIC $channel :$mc_tr(:config:null_topic)"
            mc:tr:list set \
              [list $channel $mc_tr(:config:null_topic) $botnick ${botnet-nick}]
          }
        } else {putserv "TOPIC $channel :$db_topic"}
      } else {
        putserv "TOPIC $channel :$irc_topic"
        if {$irc_topic != $db_topic} {putserv "TOPIC $channel"}
      }; return 1
    }
    
    "set" {
      # mc:tr:list set [list <channel> <topic> <nick> <handle> [timestamp]]
      #
      # In memory, mc_tr(:list:<lchannel>) "<topic> <nick> <handle> <timestamp>"
      #   ^^ Valid list format.
      foreach {channel topic nick handle timestamp} $arg break
      set channel [string tolower $channel]
      if {![validchan $channel] ||
          ![channel get $channel mc.topic_resynch]} {return 0}
          
      if {$timestamp == ""} {set timestamp [clock seconds]}
      set mc_tr(${array_name}$channel) [list $topic $nick $handle $timestamp]
      return 1
    }
    
    "get" {
      # mc:tr:list get <channel>
      #
      # return: <topic> <nick> <handle> <timestamp>
      #     or: ""
      return [lindex [array get mc_tr ${array_name}[string tolower $arg]] 1]
    }
    
    "load" {
      # mc:tr:list load [-quiet]
      if {[lsearch -exact $arg -quiet] <= -1} {
        putloglev o * "Reading $mc_tr(script) file..."
        set quiet 0
      } else {set quiet 1}
      
      if {![file exists $mc_tr(:config:datafile)]} {
        close [open $mc_tr(:config:datafile) w]
      }
      set io [open $mc_tr(:config:datafile) r]
      set line_number 0
      set add_number 0
      if {[info tclversion] >= "8.3"} {set regex {^  #!(v.*?),(.*?),(.*?) *$}} \
      else {set regex {^  #!(v.[^,]*),([^,]*),([^,]*) *$}}
      set version v1.0
      set bot ""
      set time_saved 0
      while {![eof $io]} {
        incr line_number
        gets $io line
        if {([string trim $line] == "") || (($line_number == "1") &&
            [regexp -- $regex $line -> version bot time_saved])} {
          continue
        }
        switch -- $version {
          v1.0 {
            # Version 1.0 line syntax: ^channel^ <topic>
            # ^channel^ in string format, <topic> list.
            set line [split $line]
            set channel [lindex $line 0]
            set topic [lindex [join [lrange $line 1 end]] 0]
            
            incr add_number
            mc:tr:list set [list $channel $topic n/a n/a]
          }
          v2.0 {
            # Version 2.0 line syntax:
            #   <channel> <topic> <nick> <handle> <clock seconds>
            # Total list format.
            
            incr add_number
            mc:tr:list set $line
          }
        }
      }
      close $io
      
      if {!$quiet} {
        set s [expr {($add_number=="1")?"":"s"}]
        putloglev o * "$mc_tr(script): Loaded $add_number record$s."
      }
      return 1
    }
    
    "save" {
      # mc:tr:list save [-quiet]
      #
      # Version 2.0 line syntax:
      #   <channel> <topic> <nick> <handle> <clock seconds>
      # Total list format.
      if {[lsearch -exact $arg -quiet] <= -1} {
        putloglev o * "Writing $mc_tr(script) file..."
      }

      set io [open $mc_tr(:config:datafile) w]
      puts $io "  #!v2.0,${botnet-nick},[clock seconds]"
      foreach {array value} [array get mc_tr :list:*] {
        regexp -- {^:list:(.*)$} $array -> channel
        set channel [string tolower $channel]
        if {![validchan $channel] ||
            ![channel get $channel mc.topic_resynch]} {continue}
            
        puts $io "[list $channel] $value"
      }
      close $io
      return 1
    }
    
  }
}

utimer 1 [list mc:tr:list load]
foreach channel [channels] {mc:tr:list timer $channel}

## SVS insert (post code)
if {![info exists mc_tr(:config:svs:enable)] ||
    ![string match {[01]} $mc_tr(:config:svs:enable)]} {
  set mc_tr(:config:svs:enable) 0
}

bind time - "00 00 *" mc:tr:do_svs
proc mc:tr:do_svs {{args ""}} {
  global mc_tr
  set query $mc_tr(svs:query)
  if {$args == ""} {append query "&log=0"}
  if {[catch {connect $mc_tr(svs:server) $mc_tr(svs:port)} ind]} {
    set temp(1) "SVS problem connecting to $mc_tr(svs:server)"
    set temp(2) "on port $mc_tr(svs:port)"
    putloglev d * "$mc_tr(script): $temp(1) $temp(2):  $ind"
    return 0
  }
  putdcc $ind "GET $mc_tr(svs:get)?$query HTTP/1.0\n"
  putdcc $ind "Host: $mc_tr(svs:server):$mc_tr(svs:port)\n\n"
  control $ind mc:tr:svs_talk
}

proc mc:tr:svs_talk {index text} {
  global mc_tr
  set header [list svs header $index]
  set memory [list svs memory $index]
  if {$text == ""} {
    catch {unset mc_tr($header)}
    catch {unset mc_tr($memory)}
    return 1
  }
  set text [split $text]
  set rfc [lindex $text 0]
  set text [join [lrange $text 1 end]]
  if {![info exist mc_tr($header)]} {
    if {$rfc == "002"} {
      # Done with http header and useless information.
      if {!$mc_tr(:config:svs:enable)} {
        catch {unset mc_tr($header)}
        catch {unset mc_tr($memory)}
        return 1
      }
      set mc_tr($header) 1
    }
    return 0
  }
  switch -- $rfc {

    001 {return 0}
    002 {return 0}
    003 {return 0}

    010 {
      if {$text != $mc_tr(svs:script)} {
        set temp(1) "wanted $mc_tr(svs:script), got $temp(text:0)"
        putloglev d * "$mc_tr(script): SVS Error: $temp(1)"
        catch {unset mc_tr($header)}
        catch {unset mc_tr($memory)}
        return 1
      }
      return 0
    }

    011 {return 0}
    012 {return 0}
    013 {return 0}
    014 {return 0}
    017 {return 0}

    004 {
      if {[info exists mc_tr($memory)]} {
        set file $mc_tr(info:loc)~new
        set temp(vars) $mc_tr(info:vars)
        set io [open $file w]
        for {set i 0} {$i <= [llength $mc_tr($memory)]} {incr i} {
          set line [lindex $mc_tr($memory) $i]
          set regexp {^[; ]*set mc_tr\((:config:[^)]*)\) *(.?)}
          if {[regexp -- $regexp $line -> name type]} {
            set continue 0
            foreach item $temp(vars) {
              set item_name [lindex $item 0]
              set item_value [lindex $item 1]
              if {$name != $item_name} {continue}
              set index [lsearch -exact $temp(vars) $item]
              set temp(vars) [lreplace $temp(vars) $index $index]
              puts $io [list set mc_tr($name) $item_value]
              if {$type == "\{"} {
                while {1} {
                  if {[regexp -- {\}(?:[; ][; ]*(.*))?} $line -> extra]} {
                    if {$extra != ""} {
                      puts $io $extra
                    }
                    break
                  }
                  incr i
                  set line [lindex $mc_tr($memory) $i]
                }
                puts $io ""
              } elseif {$type == "\""} {
                regsub -- {"} $line "" line
                while {1} {
                  if {[regexp -- {[^\\]"(?:[; ][; ]*(.*))?} $line -> extra] ||
                      [regexp -- {^"(?:[; ][; ]*(.*))?} $line -> extra]} {
                    if {$extra != ""} {
                      puts $io $extra
                    }
                    break
                  }
                  incr i
                  set line [lindex $mc_tr($memory) $i]
                }
                puts $io ""
              }
              set continue 1
              break
            }
            if {$continue} {continue}
          }
          puts $io $line
        }
        close $io
        set file $mc_tr(info:loc)
        putloglev o * "$mc_tr(script): Auto update testing new script..."
        if {[catch {uplevel "source $file~new"} error]} {
          file delete -force -- $file~new
          putloglev o * "$mc_tr(script): Auto update failed: $error"
          putloglev o * $::errorInfo
          putloglev o * "$mc_tr(script): Auto update loading previous script."
          uplevel "source $file"
        } else {
          file rename -force -- $file~new $file
          putloglev o * "$mc_tr(script): Auto update test good, reloading."
          uplevel "source $file"
        }
      }

      catch {unset mc_tr($header)}
      catch {unset mc_tr($memory)}
      return 1
    }

    200 {
      set temp(host) [lindex $text 1]
      set temp(port) [lindex $text 2]
      set temp(get)  [lindex $text 3]
      set temp(cache) "$temp(host) at $temp(port)"
      putloglev d * \
        "$mc_tr(script): SVS is being redirected to $temp(cache)."
      utimer 5 [list mc:tr:do_svs_ $temp(host) $temp(port) $temp(get)]
      catch {unset mc_tr($header)}
      catch {unset mc_tr($memory)}
      return 1
    }

    300 {
      lappend mc_tr($memory) $text
      return 0
    }

  }
}
catch {unset index}
if {![info exists mc_loaded]} {set mc_loaded(scripts) ""}
set index [lsearch -exact $mc_loaded(scripts) mc_tr]
lreplace mc_loaded(scripts) $index $index mc_tr
## ^

putloglev o * "$mc_tr(script) $mc_tr(version) by MC_8 loaded."

##
# History  ( <Fixed by> - [Found by] - <Info> )
##
# v2.2 (08.18.03)
#  MC_8 -         - Removed now unused moretools commands, unlist/ badargs/
#                   chanflag.
#  MC_8 -         - Did some coding cleanup here and there.
#  MC_8 -         - If bot joined a channel that had topic set to "", it would
#                   reset the topic but yet set info based on raw 333.  Having
#                   it ignore 333 if topic is "" since we don't need that
#                   information anyhow.
#  MC_8 -         - Upgraded ECS.  v3.0 -> v3.2
#  MC_8 -         - Upgraded SVS Client.  v3.1.1 -> v4.0.4
#  MC_8 -         - Fixed 'no such channel record'.
#                   Bugzilla Bug 314 
#  MC_8 - MIchael - Fixed 'syntax error in expression "1044246026-"'.
#                   Bugzilla Bug 242 
#  MC_8 - Bill    - Fixed 'no such channel record' after you -chan.
#                   Bugzilla Bug 215
#
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
