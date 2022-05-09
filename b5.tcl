# This script is created by NSG2 beta1
# <http://wushoupong.googlepages.com/nsg>

#===================================
#     Simulation parameters setup
#===================================
set val(stop)   10.0                         ;# time of simulation end

#===================================
#        Initialization        
#===================================
#Create a ns simulator
set ns [new Simulator]

#Open the NS trace file
set tracefile [open out.tr w]
$ns trace-all $tracefile

#Open the NAM trace file
set namfile [open out.nam w]
$ns namtrace-all $namfile

#===================================
#        Nodes Definition        
#===================================
#Create 4 nodes
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]

#===================================
#        Links Definition        
#===================================
#Createlinks between nodes
$ns duplex-link $n2 $n0 1.0Mb 10ms DropTail
$ns queue-limit $n2 $n0 50
$ns duplex-link $n1 $n2 1.0Mb 10ms DropTail
$ns queue-limit $n1 $n2 50
$ns duplex-link $n3 $n2 1.0Mb 10ms DropTail
$ns queue-limit $n3 $n2 50

#Give node position (for NAM)
$ns duplex-link-op $n2 $n0 orient left-up
$ns duplex-link-op $n1 $n2 orient left-down
$ns duplex-link-op $n3 $n2 orient right-up

#===================================
#        Agents Definition  
set tcp1 [new Agent/TCP]
$ns attach-agent $n0 $tcp1
set tcp2 [new Agent/TCP]
$ns attach-agent $n1 $tcp2

set sink1 [new Agent/TCPSink] 
$ns attach-agent $n3 $sink1
$ns connect $tcp1 $sink1
set sink2 [new Agent/TCPSink] 
$ns attach-agent $n3 $sink2
$ns connect $tcp2 $sink2   
   
#===================================
#create Telnet Application for Tcp Agent
set telnet0 [new Application/Telnet]
$telnet0 set interval_ 0.005
$telnet0 attach-agent $tcp2
#===================================
#        Applications Definition        
#===================================
#Setup a FTP Application over TCP connection
set ftp0 [new Application/FTP]
$ftp0 attach-agent $tcp1
$ns at 1.0 "$ftp0 start"
$ns at 2.0 "$ftp0 stop"
set telnet0 [new Application/Telnet]
$telnet0 attach-agent $tcp2
$ns at 0.5 "$telnet0 start"
$ns at 4.5 "$telnet0 stop"



#===================================
#        Termination        
#===================================
#Define a 'finish' procedure
proc finish {} {
    global ns tracefile namfile
    $ns flush-trace
    close $tracefile
    close $namfile
    exec nam out.nam &
    exec awk -f prg5.awk out.tr&
    exit 0
}
$ns at $val(stop) "$ns nam-end-wireless $val(stop)"
$ns at $val(stop) "finish"
$ns at $val(stop) "puts \"done\" ; $ns halt"
$ns run

