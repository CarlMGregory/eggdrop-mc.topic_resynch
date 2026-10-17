##
# Topic Resynch v1.1 by \-\iTman <??> && (Carl M. Gregory) MC_8 <gregory@worldinter.net>
##
# This script keeps the topic synched.  Helps avoid topics getting lost in
# net-split/join's.
##

##
# Commands:
#  DCC:
#   tr ----------------- Preforms the Topic Resynch.
#   trsave ------------- Saves the topic synch database.
#   trtopic [#channel] - Shows you what the topics are currently saved as, if no channel
#                        specified then it will list all you have this script activated on.
#   trchannels --------- Shows you what channels this script is monitoring.
##

##
# History
##
# v1.1 (05.30.00)
#  MC_8 & \-\iTman - This script actually took shape a long time ago, some time in the fall
#                    of 98`, I got a stable build working and kinda forgot about it in my
#                    pile of mc.* scripts.  Anyhow, here it is probably a half year later.
##

# Set this to the channels this would only work on.  If set to "", it will 
# be active on ALL channels that bot is on.
set himc(channels) ""

# Set this to the name of the datafile that will be used to
# keep the topic information in.
set himc(datafile) topic.dat

# Set this to how often (in min's) to re`synch the topic.
set himc(topicres) 60

##### scripting starts here ######
set himc(version) v1.1

proc himc:bold {} {return }

bind topc o|o * himc:topic:n
proc himc:topic:n {nick uhost hand chan topic} {
 global himc botnick
 set chan [string tolower $chan]
 if {$nick == $botnick} {return 0}
 if {$himc(channels) == ""} {set himc(channel) [string tolower [channels]]} {
  set himc(channel) $himc(channels)
 }
 if {[lsearch -exact $himc(channel) $chan] == "-1"} {return 0}
 if {[info exists himc(_$chan)] && ($himc(_$chan) == $topic)} {return 0}
 set himc(_$chan) $topic
 putlog "[himc:bold]Topic Resynch[himc:bold]: $nick (hand: $hand) reset the lock for $chan."
}

proc himc:load {file} {
 set buffer 0
 if {![file exists $file]} {
  putlog "[himc:bold]Topic Resynch[himc:bold]: Loading $file, cannot be found, creating a new one opon auto-save."
  return 0
 } ; set datafile [open $file r]
 while {![eof $datafile]} {
  set line [gets $datafile]
  if {[lindex $line 0] != ""} {
   set himc(_[string tolower [lindex $line 0]]) [lindex $line 1]
   incr buffer 1
  }
 } ; close $datafile
 if {$buffer == 1} {
  putlog "[himc:bold]Topic Resynch[himc:bold]: $file loaded, $buffer entrie pulled for use."
 } {putlog "[himc:bold]Topic Resynch[himc:bold]: $file loaded, $buffer entries pulled for use."}
 return 1
}

proc himc:save {file} {
 global himc ; set i 0 ; set himc_find 1
 if {![file exists $file]} {set himc_find 0} {file delete $file} ; set s 0
 if {$himc(channels) == ""} {set himc(channel) [string tolower [channels]]} {
  set himc(channel) $himc(channels)
 }
 foreach name $himc(channel) {
  set skip 0
  if {![info exists himc(_$name)]} {
   set topic [topic $name]
   if {$topic == ""} {
    incr s 1 ; set skip 1
   } {set himc(_$name) $topic}
  }
  if {!$skip} {
   set datafile [open $file w] ; puts $datafile "$name {[mchi:filt $himc(_$name)]}"
   close $datafile
   incr i 1
  }
 }
 if {$i == 1} {
  if {!$himc_find} {
   putlog "[himc:bold]Topic Resynch[himc:bold]: New database created."
  }
  putlog "[himc:bold]Topic Resynch[himc:bold]: Saved $i entrie to $file."
 } {
  if {!$i && !$himc_find} {
   putlog "[himc:bold]Topic Resynch[himc:bold]: New database creation not done,"
  }
  if {$i && !$himc_find} {
   putlog "[himc:bold]Topic Resynch[himc:bold]: New database created."
  }
  if {!$s} {
   putlog "[himc:bold]Topic Resynch[himc:bold]: Saved $i entries to $file."
  } {
   if {$s == 1} {
    putlog "[himc:bold]Topic Resynch[himc:bold]: Saved $i entries to $file.  $s entrie skiped due to no topic record."
   } {
    putlog "[himc:bold]Topic Resynch[himc:bold]: Saved $i entries to $file.  $s entries skiped due to no topic record."
   }
  }
 }
}
 
proc himc:timesave {min hour day month year} {
 global himc
 himc:save $himc(datafile)
}

bind dcc o trsave himc:dccsave
proc himc:dccsave {hand idx args} {
 global himc
 himc:save $himc(datafile)
}

set himc(channels) [string tolower $himc(channels)]
himc:load $himc(datafile)

proc himc:topic:r {} {
 global himc ; set i 0 ; set b 0
 if {$himc(channels) == ""} {set himc(channel) [string tolower [channels]]} {
  set himc(channel) $himc(channels)
 }
 foreach chan $himc(channel) {
  if {![validchan $chan]} {
   putlog "[himc:bold]Topic Resynch[himc:bold]: Your veriables say to monitor $chan, but I'm not show it a valid channel?!"
  } {
   set topic [topic $chan]
   if {$topic == ""} {
    if {[info exists himc(_$chan)]} {
     if {[botisop $chan]} {
      if {$himc(_$chan) == ""} {
       putlog "[himc:bold]Topic Resynch[himc:bold]: Trying to resynch $chan, records show is's \"\" (nothing).. skipping."
      } {
       puthelp "TOPIC $chan :$himc(_$chan)" ; incr i 1
      }
     } {
      putlog "[himc:bold]Topic Resynch[himc:bold]: Trying to resynch $chan, but I'm not op'd.. skipping."
     }
    } {
     if {[botonchan $chan]} {
      putlog "[himc:bold]Topic Resynch[himc:bold]: Trying to resynch $chan, but I don't have any previous topics in my database.. skipping."
     } {
      putlog "[himc:bold]Topic Resynch[himc:bold]: Trying to resynch $chan, but I'm not even in there?!"
     }
    }
   } {
    if {[botisop $chan]} {puthelp "TOPIC $chan :$topic" ; incr i 1} {
     putlog "[himc:bold]Topic Resynch[himc:bold]: Trying to resynch $chan, but I'm not op'd.. skipping."
    } ; if {$himc(_$chan) != $topic} {set himc(_$chan) $topic ; incr b 1}
   }
  }
 }
 putlog "[himc:bold]Topic Resynch[himc:bold]: Resynched $i out of [llength $himc(channel)] channels' topics, $b new topics saved."
 if {![string match *himc:topic:r* [timers]]} {timer $himc(topicres) himc:topic:r}
}

if {![string match *himc:topic:r* [timers]]} {timer $himc(topicres) himc:topic:r}

bind dcc o tr himc:topic:dcc:r
proc himc:topic:dcc:r {hand idx args} {
 himc:topic:r
}

bind dcc o trtopic himc:topic:show
proc himc:topic:show {hand idx args} {
 global himc
 if {$himc(channels) == ""} {set himc(channel) [string tolower [channels]]} {
  set himc(channel) $himc(channels)
 }
 if {([string index [set args [string tolower [lindex [lindex $args 0] 0]]] 0] != "#") &&
     ($args != "")} {putdcc $idx "[himc:bold]Topic Resynch[himc:bold]: SYNTAX: trtopic \[#channel\]" ; return 0}
 if {($args != "") && ([lsearch -exact $himc(channel) $args] == "-1")} {
  putdcc $idx "[himc:bold]Topic Resynch[himc:bold]: I do not monitor $args.  Try: .trchannels" ; return 0
 }
 if {$args == ""} {
  putdcc $idx "Listing..." ; set i 0 ; set s 0
  foreach chan $himc(channel) {
   if {[info exists himc(_$chan)]} {
    putdcc $idx "- $chan :: $himc(_$chan)" ; incr i 1
   } {
    set topic [topic $chan]
    if {$topic != ""} {
     set himc(_$chan) $topic ; putdcc $idx "- $chan :: $topic" ; incr i 1
    } {
     putdcc $idx "- $chan :: -=unable to determin topic=-" ; incr s 1 ; incr i 1
    }
   }
  }
  if {$i == 1} {
   if {!$s} {
    putdcc $idx "EOF, monitoring $i channel."
   } {
    if {$s == 1} {
     putdcc $idx "EOF, monitoring $i channel.  $s was unable to find a topic!"
    } {
     putdcc $idx "EOF, monitoring $i channel.  $s were unable to find a topic!"
    }
   }
  } {
   if {!$s} {
    putdcc $idx "EOF, monitoring $i channels."
   } {
    if {$s == 1} {
     putdcc $idx "EOF, monitoring $i channels.  $s was unable to find a topic!"
    } {
     putdcc $idx "EOF, monitoring $i channels.  $s were unable to find a topic!"
    }
   }
  }
 } {
  putdcc $idx "Listing..." ; set chan $args
  if {[info exists himc(_$chan)]} {
   putdcc $idx "- $chan :: $himc(_$chan)"
  } {
   set topic [topic $chan]
   if {$topic != ""} {
    set himc(_$chan) $topic
    putdcc $idx "- $chan :: $topic"
   } {
    putdcc $idx "- $chan :: -=unable to determin topic=-"
   }
  }
  putdcc $idx "EOF for $chan."
 }
}

bind dcc o trchannels himc:show:channels
proc himc:show:channels {hand idx args} {
 global himc
 if {$himc(channels) == ""} {set himc(channel) [string tolower [channels]]} {
  set himc(channel) $himc(channels)
 }
 putdcc $idx "[himc:bold]Topic Resynch[himc:bold]: I'm supporting: [join $himc(channel) ", "]."
}

if {$himc(channels) == ""} {set himc(channel) [string tolower [channels]]} {
 set himc(channel) $himc(channels)
}
if {$server != ""} {
 foreach chan $himc(channel) {
  putserv "TOPIC $chan"
 }
}

bind raw - 333 himc:topic:who
proc himc:topic:who {from key args} {
 global himc
 set args [lindex $args 0] 
 set chan [string tolower [lindex $args 1]]
 set who [lindex $args 2]
 if {$himc(channels) == ""} {set himc(channel) [string tolower [channels]]} {
  set himc(channel) $himc(channels)
 }
 if {[lsearch -exact $himc(channel) $chan] == "-1"} {return 0}
 set topic [topic $chan]
 if {[info exists himc(_$chan)] && ($himc(_$chan) == $topic)} {return 0} {
  set himc(_$chan) $topic
 }
 putlog "[himc:bold]Topic Resynch[himc:bold]: Updating record for $chan."
 return 0
}

proc mchi:filt {data} {
 regsub -all -- \\\\ $data \\\\\\\\ data ; regsub -all -- \\\[ $data \\\\\[ data ; regsub -all -- \\\] $data \\\\\] data
 regsub -all -- \\\} $data \\\\\} data ; regsub -all -- \\\{ $data \\\\\{ data ; regsub -all -- \\\" $data \\\\\" data ; return $data
}

bind time - "39 * * * *" himc:timesave
bind time - "09 * * * *" himc:timesave

putlog "[himc:bold]Topic Resynch[himc:bold] $himc(version) by \\-\\iTman && MC_8 loaded."