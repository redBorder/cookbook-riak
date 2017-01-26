Name: cookbook-riak
Version: %{__version}
Release: %{__release}%{?dist}
BuildArch: noarch
Summary: Riak cookbook to install and configure it in redborder environments

License: AGPL 3.0
URL: https://github.com/redBorder/cookbook-riak
Source0: %{name}-%{version}.tar.gz

%description
%{summary}

%prep
%setup -qn %{name}-%{version}

%build

%install
mkdir -p %{buildroot}/var/chef/cookbooks/riak
cp -f -r  resources/* %{buildroot}/var/chef/cookbooks/riak
chmod -R 0755 %{buildroot}/var/chef/cookbooks/riak
install -D -m 0644 README.md %{buildroot}/var/chef/cookbooks/riak/README.md

%pre

%post

%files
%defattr(0755,root,root)
/var/chef/cookbooks/riak
%defattr(0644,root,root)
/var/chef/cookbooks/riak/README.md


%doc

%changelog
* Thu Jan 26 2017 Carlos J. Mateos <cjmateos@redborder.com> - 1.0.0-1
- first spec version
