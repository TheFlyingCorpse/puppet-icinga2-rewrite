require 'spec_helper'

describe('icinga2', :type => :class) do

  let(:facts) { facts.merge({ :architecture => 'x86_64' }) }

  before(:all) do
    @icinga2_conf = "/etc/icinga2/icinga2.conf"
    @constants_conf = "/etc/icinga2/constants.conf"

    @windows_icinga2_conf = "C:/ProgramData/icinga2/etc/icinga2/icinga2.conf"
    @windows_constants_conf = "C:/ProgramData/icinga2/etc/icinga2/constants.conf"
  end

  on_supported_os.each do |os, facts|
    let :facts do
      facts
    end

    context "#{os} with all default parameters" do
      it { is_expected.to contain_package('icinga2').with({ 'ensure' => 'installed' }) }

      it { is_expected.to contain_service('icinga2').with({
        'ensure' => 'running',
        'enable' => true
        })
      }

      case facts[:osfamily]
      when 'Debian'
        it { is_expected.to contain_file(@constants_conf)
          .with_content %r{^const PluginDir = \"/usr/lib/nagios/plugins\"\n} }

        it { is_expected.to contain_file(@constants_conf)
          .with_content %r{^const PluginContribDir = \"/usr/lib/nagios/plugins\"\n} }

        it { is_expected.to contain_file(@constants_conf)
          .with_content %r{^const ManubulonPluginDir = \"/usr/lib/nagios/plugins\"\n} }
      when 'RedHat'
        let(:facts) { facts.merge({ :osfamily => 'RedHat' }) }
        it { is_expected.to contain_file(@constants_conf)
          .with_content %r{^const PluginDir = \"/usr/lib64/nagios/plugins\"\n} }

        it { is_expected.to contain_file(@constants_conf)
          .with_content %r{^const PluginContribDir = \"/usr/lib64/nagios/plugins\"\n} }

        it { is_expected.to contain_file(@constants_conf)
          .with_content %r{^const ManubulonPluginDir = \"/usr/lib64/nagios/plugins\"\n} }
      end

      it { is_expected.to contain_file(@constants_conf)
        .with_content %r{^const NodeName = \".+\"\n} }

      it { is_expected.to contain_file(@constants_conf)
        .with_content %r{^const ZoneName = \".+\"\n} }

      it { is_expected.to contain_file(@constants_conf)
        .with_content %r{^const TicketSalt = \"\"\n} }

      it { is_expected.to contain_file(@icinga2_conf)
        .with_content %r{^// managed by puppet\n} }

      it { is_expected.to contain_file(@icinga2_conf)
        .with_content %r{^include <plugins>\n} }

      it { is_expected.to contain_file(@icinga2_conf)
        .with_content %r{^include <plugins-contrib>\n} }

      it { is_expected.to contain_file(@icinga2_conf)
        .with_content %r{^include <windows-plugins>\n} }

      it { is_expected.to contain_file(@icinga2_conf)
        .with_content %r{^include <nscp>\n} }

      it { is_expected.to contain_file(@icinga2_conf)
        .with_content %r{^include_recursive \"conf.d\"\n} }

      it { is_expected.to contain_icinga2__feature('checker')
        .with({'ensure' => 'present'}) }

      it { is_expected.to contain_icinga2__feature('mainlog')
        .with({'ensure' => 'present'}) }

      it { is_expected.to contain_icinga2__feature('notification')
        .with({'ensure' => 'present'}) }

      case facts[:osfamily]
      when 'Debian'
        it { should_not contain_apt__source('icinga-stable-release') }
      when 'RedHat'
        it { should_not contain_yumrepo('icinga-stable-release') }
      end
    end
  end

  context 'Windows 2012 R2 with all default parameters' do
    let(:facts) { {
      :kernel => 'Windows',
      :architecture => 'x86_64',
      :osfamily => 'Windows',
      :operatingsystem => 'Windows',
      :operatingsystemmajrelease => '2012 R2'
    } }

    it { is_expected.to contain_package('icinga2').with({ 'ensure' => 'installed' }) }

    it { is_expected.to contain_service('icinga2').with({
      'ensure' => 'running',
      'enable' => true
      })
    }



    it { is_expected.to contain_file(@windows_constants_conf)
      .with_content %r{^const PluginDir = \"C:/Program Files/ICINGA2/sbin\"\r\n} }

    it { is_expected.to contain_file(@windows_constants_conf)
      .with_content %r{^const PluginContribDir = \"C:/Program Files/ICINGA2/sbin\"\r\n} }

    it { is_expected.to contain_file(@windows_constants_conf)
      .with_content %r{^const ManubulonPluginDir = \"C:/Program Files/ICINGA2/sbin\"\r\n} }

    it { is_expected.to contain_file(@windows_constants_conf)
      .with_content %r{^const NodeName = \".+\"\r\n} }

    it { is_expected.to contain_file(@windows_constants_conf)
      .with_content %r{^const ZoneName = \".+\"\r\n} }

    it { is_expected.to contain_file(@windows_constants_conf)
      .with_content %r{^const TicketSalt = \"\"\r\n} }

    it { is_expected.to contain_file(@windows_constants_conf)
      .with_content %r{^} }

    it { is_expected.to contain_file(@windows_icinga2_conf)
      .with_content %r{^// managed by puppet\r\n} }

    it { is_expected.to contain_file(@windows_icinga2_conf)
      .with_content %r{^include <plugins>\r\n} }

    it { is_expected.to contain_file(@windows_icinga2_conf)
      .with_content %r{^include <plugins-contrib>\r\n} }

    it { is_expected.to contain_file(@windows_icinga2_conf)
      .with_content %r{^include <windows-plugins>\r\n} }

    it { is_expected.to contain_file(@windows_icinga2_conf)
      .with_content %r{^include <nscp>\r\n} }

    it { is_expected.to contain_file(@windows_icinga2_conf)
      .with_content %r{^include_recursive \"conf.d\"\r\n} }

    it { is_expected.to contain_icinga2__feature('checker')
      .with({'ensure' => 'present'}) }

    it { is_expected.to contain_icinga2__feature('mainlog')
      .with({'ensure' => 'present'}) }

    it { is_expected.to contain_icinga2__feature('notification')
      .with({'ensure' => 'present'}) }
  end


  context 'on unsupported plattform' do
    let(:facts) { {:osfamily => 'foo'} }
    it { is_expected.to raise_error(Puppet::Error, /foo is not supported/) }
  end

end
