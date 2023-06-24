# escape=`

FROM mcr.microsoft.com/windows/servercore:ltsc2022-KB5026370

# Reset the shell.
SHELL ["powershell"]

ADD https://dot.net/v1/dotnet-install.ps1 c:\dotnet-install.ps1

RUN ./dotnet-install.ps1 -Channel 7.0 -InstallDir C:\dotnet\

RUN [Environment]::SetEnvironmentVariable(\"Path\", $env:Path + \";c:\\dotnet\", [EnvironmentVariableTarget]::Machine)

RUN dotnet --list-sdks

# Fix 260 character path limit
RUN Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem' -Name LongPathsEnabled -Type DWord -Value 1

###############################################################################
# Git
###############################################################################
ARG GIT_VERSION=2.37.2.2
ADD https://artifactory.aeons.dev/artifactory/aeon-cdn/tools/x86_64_windows/git/git-${GIT_VERSION}.zip C:\git.zip
RUN expand-archive -Path 'c:\git.zip' -DestinationPath 'c:\'
ENV GIT_ROOT_PATH="C:\git-${GIT_VERSION}\"
RUN [Environment]::SetEnvironmentVariable(\"Path\", $env:Path + \";$env:GIT_ROOT_PATH\bin\;\", [EnvironmentVariableTarget]::Machine)

###############################################################################
# Java JRE
###############################################################################
ADD jdk-20_windows-x64_bin.zip c:\jdk-20_windows-x64_bin.zip
RUN expand-archive -Path 'c:\jdk-20_windows-x64_bin.zip' -DestinationPath 'c:\'
RUN [Environment]::SetEnvironmentVariable(\"Path\", $env:Path + \";c:\jdk-20.0.1\bin\;\", [EnvironmentVariableTarget]::Machine)

RUN java -version

###############################################################################
# Setup SSH and additional workloads
###############################################################################

RUN mkdir c:\Users\ContainerAdministrator\.ssh\
ADD id_ed25519 c:\Users\ContainerAdministrator\.ssh\id_ed25519
ADD known_hosts c:\Users\ContainerAdministrator\.ssh\known_hosts

RUN git clone git@cgit.aeons.dev:private/aleya/aleya.git c:\tmprepo
RUN cd c:\tmprepo ; Remove-Item -Path nuget.config ; dotnet workload restore

RUN mkdir C:\Nuget\
ADD https://dist.nuget.org/win-x86-commandline/latest/nuget.exe c:\Nuget\nuget.exe
RUN [Environment]::SetEnvironmentVariable(\"Path\", $env:Path + \";c:\Nuget\;\", [EnvironmentVariableTarget]::Machine)

###############################################################################
# Jenkins Slave
###############################################################################
run mkdir c:\ProgramData\Jenkins\
ADD http://172.18.0.4:8080/jnlpJars/agent.jar c:\ProgramData\Jenkins\agent.jar
ADD slave-launch.ps1 c:\slave-launch.ps1
ENTRYPOINT powershell.exe -ExecutionPolicy ByPass -File c:\slave-launch.ps1
