#!/usr/bin/env perl

use strict;
use warnings;
use autodie;
use File::Spec;
use FindBin;
use Path::Class qw/dir/;
use YAML;

&main();

sub main {
    my $dir = dir(File::Spec->rel2abs($FindBin::Bin).'/../lib/Jubatus/');
    my @use_modules;
    my @get_clients;
    my @module_names;
    my %cache = ();
    while (my $dir_path = $dir->next) {
        my $subdir = dir($dir_path);
        my $dir = $subdir->{dirs}->[-1];
        next if ($dir =~ m|^.+\.pm$|);
        while (my $subdir_path = $subdir->next) {
            if ((exists $subdir_path->{file}) && ($subdir_path->{file} =~ m|Client.pm|)){
                my $module_name =  $subdir_path->{dir}->{dirs}->[-1];
                next if (exists $cache{$module_name});
                $cache{$module_name} = 1;
                use YAML; print Dump $module_name;
                my $name_space = "Jubatus::".$module_name."::Client";
                push @use_modules, "use ".$name_space.";";
                my $get_client = &get_client_getter($name_space, $module_name);
                push @get_clients, $get_client;
                push @module_names, $module_name;
            }
        }
    }
    my $use_auto_gen_module = join "\n", @use_modules;
    my $get_client_from_auto_gen_module = join "\n", @get_clients;
    my $get_client_from_auto_gen_module_using_parameter = &get_client_getter_using_parameter(\@module_names);
    my $jubatus_pm_tmpl_path = $FindBin::Bin."/../tmpl/jubatus_pm_tmpl";
    my $jubatus_pm_path = $FindBin::Bin."/../lib/Jubatus.pm";
    open my $in, "<:utf8", $jubatus_pm_tmpl_path;
    open my $out, ">:utf8", $jubatus_pm_path;
    while (my $line = <$in>) {
        if ($line =~ m|#### USE ALL AUTO GENERATE MODULES ####|) {
            print $out $use_auto_gen_module."\n";
        }
        elsif ($line =~ m|#### GET CLIENT FROM AUTO GENERATE MODULES ####|) {
            print $out $get_client_from_auto_gen_module."\n";
        }
        elsif ($line =~ m|#### GET CLIENT FROM AUTO GENERATE MODULES USING PARAMETER ####|) {
            print $out $get_client_from_auto_gen_module_using_parameter."\n";
        }
        else {
            print $out $line;
        }
    }
    close $out;
    close $in;
    return;
}

sub get_client_getter_using_parameter {
    my ($module_names) = @_;

    my $getter = "";

    my $tmpl_head = <<'__TMPL_HEAD__';
sub get_client {
    my ($self, $param, $host, $port, $name, $timeout) = @_;
    my $client;
    given ($param) {
__TMPL_HEAD__
    $getter .= $tmpl_head;

    foreach my $module_name (@{$module_names}) {
        my $module_name_nc = $module_name;
        $module_name_nc =~ tr|[A-Z]|[a-z]|;

        my $tmpl_body = <<'__TMPL_BODY__';
        when (/^==MODULE_NAME==|==MODULE_NAME_NC==$/) {
            $client = Jubatus->get_==MODULE_NAME_NC==_client($host, $port, $name, $timeout);
        }
__TMPL_BODY__

        $tmpl_body =~ s|==MODULE_NAME==|$module_name|g;
        $tmpl_body =~ s|==MODULE_NAME_NC==|$module_name_nc|g;

        $getter .= $tmpl_body;
    }

    my $tmpl_tail = <<'__TMPL_TAIL__';
        default {
            die "Jubatus::".$param."::Client.pm is not install.\n Please see Jubatus.pm !\n";
        }
    }
    return $client;
}
__TMPL_TAIL__

    $getter .= $tmpl_tail;
    return $getter;
}


sub get_client_getter {
    my ($name_space, $module_name) = @_;
    my $module_name_nc = $module_name;
    $module_name_nc =~ tr|[A-Z]|[a-z]|;
    my $tmpl = <<'__TMPL__';
sub get_==MODULE_NAME_NC==_client {
    my ($self, $host, $port, $name, $timeout) = @_;
    my $client = ==NAMESPACE==->new($host, $port, $name, $timeout);
    return $client;
}
__TMPL__
    $tmpl =~ s|==MODULE_NAME_NC==|$module_name_nc|;
    $tmpl =~ s|==NAMESPACE==|$name_space|;
    return $tmpl;
}
