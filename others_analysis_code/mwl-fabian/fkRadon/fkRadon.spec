Summary: fkRadon Toolbox
Name: fkRadon
Version: 0.1
Release: 3
License: GPL
Group: MWL
Prefix: /opt/matlabR14
Requires: matlabR14 >= 7.0.1
BuildArch: i386
URL: http://www.mwl.mit.edu/
Source0: %{name}-%{version}-%{release}.%{buildarch}.tar.gz
BuildRoot: %{_tmppath}/%{name}-buildroot
AutoReqProv: no # don't try to figure out deps from the shared library (.so) files

%description
This package contains a library of useful matlab functions

#### DEFINES

# don't build debug libs from .so files
# %define debug_package %{nil}

#### PREP
%prep
rm -Rf $RPM_BUILD_ROOT
mkdir $RPM_BUILD_ROOT


#### SETUP
%setup -n %{name}


#### BUILD
%build


#### PRE-INSTALL
%pre

#check whether matlab is installed in $RPM_INSTALL_PREFIX

if [ -e "$RPM_INSTALL_PREFIX/bin/matlab" ] && [ -e "$RPM_INSTALL_PREFIX/toolbox/local/pathdef.m" ]; then
  true
else
  echo "INSTALL ERROR: matlab not found in installation directory"
  false
fi


#### INSTALL
%install
rm -rf $RPM_BUILD_ROOT

#make directory and copy everything over
mkdir -p $RPM_BUILD_ROOT/opt/matlabR14/toolbox/%{name}
cp -rf $RPM_BUILD_DIR/fkRadon/* $RPM_BUILD_ROOT/opt/matlabR14/toolbox/%{name}

#make help directory and copy help files over, remove original help directory
mkdir -p $RPM_BUILD_ROOT/opt/matlabR14/help/toolbox/%{name}
mv -f $RPM_BUILD_ROOT/opt/matlabR14/toolbox/%{name}/html/* $RPM_BUILD_ROOT/opt/matlabR14/help/toolbox/%{name}
rm -rf $RPM_BUILD_ROOT/opt/matlabR14/toolbox/%{name}/html

#change help file location in info.xml
sed -i -e "s/\(<help_location>\).*\(<\/help_location>\)/\1\$docroot\/toolbox\/fkRadon\2/" $RPM_BUILD_ROOT/opt/matlabR14/toolbox/%{name}/info.xml

#change start menu item to use doc instead of help
sed -i -e "s/help\( fkRadon\)/doc\1/" $RPM_BUILD_ROOT/opt/matlabR14/toolbox/%{name}/info.xml


#### POST-INSTALL
%post
if [ "$1" = "1" ] ; then  # first install
#  cp /opt/matlabR14/toolbox/local/pathdef.m /opt/matlabR14/toolbox/local/pathdef.m.backup
  sed -i -e "s/[ ]\{4,\}[.]\{3\}/matlabroot,'\/toolbox\/fkRadon:',...\n     .../g" $RPM_INSTALL_PREFIX/toolbox/local/pathdef.m
fi


#### PRE-UNINSTALL 
%preun


#### POST-UNINSTALL
%postun
if [ "$1" = "0" ] ; then  # last uninstall
  sed -i -e "/fkRadon/d" $RPM_INSTALL_PREFIX/toolbox/local/pathdef.m
fi

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root)
# don't mark this as config so we update them by default
%docdir /opt/matlabR14/help/toolbox/%{name}
/opt/matlabR14/toolbox/%{name}
/opt/matlabR14/help/toolbox/%{name}

%changelog


