require 'spec_helper'

describe 'sssd' do
  context 'supported operating systems' do
    ['RedHat'].each do |osfamily|
      describe "sssd class without any parameters on #{osfamily}" do
        let(:params) {{ }}
        let(:facts) {{
          :osfamily => osfamily,
        }}

        it { should compile.with_all_deps }
        describe 'sssd class' do
          it { should contain_class('sssd::params') }
          it { should contain_class('sssd::install').that_comes_before('sssd::config') }
          it { should contain_class('sssd::config') }
          it { should contain_class('sssd::service').that_subscribes_to('sssd::config') }
        end
	describe 'sssd::install class' do
          it { should contain_service('sssd') }
          it { should contain_package('sssd').with_ensure('present') }
	end
	describe 'sssd::config class' do
	  it { should contain_file('File[sssd_config_file]').with({
	    :path  => '/etc/sssd/sssd.conf',
	    :owner => 'root',
	    :group => 'root',
	    :mode  => '0600'
	  }) }
	  it { should contain_file('File[sssd_config_file]').with_content(/services = nss,pam/) }
	end
	describe 'sssd::service class' do
	end
      end
      describe "sssd class with some custom parameters on #{osfamily}" do
        let(:params) {{
	  :config => {
	    'domain/AD' => {
	      'ldap_force_upper_case_realm' => false,
	    },
	    'domain/LDAP' => {
	      'cache_credentials' => false,
	    },
	    'sssd' => {
	      'domains' => ['AD','LDAP'],
	    },
	  }
	}}
        let(:facts) {{
          :osfamily => osfamily,
        }}

        it { should compile.with_all_deps }
	describe 'sssd::config class' do
	  it { should contain_file('File[sssd_config_file]').with_content(/domains = AD,LDAP/) }
	  it { should contain_file('File[sssd_config_file]').with_content(/cache_credentials = false/) }
	  it { should contain_file('File[sssd_config_file]').with_content(/ldap_force_upper_case_realm = false/) }
	end
      end
    end
  end

  context 'unsupported operating system' do
    describe 'sssd class without any parameters on Solaris/Nexenta' do
      let(:facts) {{
        :osfamily        => 'Solaris',
        :operatingsystem => 'Nexenta',
      }}

      it { expect { should contain_package('sssd') }.to raise_error(Puppet::Error, /Nexenta not supported/) }
    end
  end
end
