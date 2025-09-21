
# Print MOTD
hostname=$(hostname | cut -d . -f 1)
hostname="${(C)hostname}"
figlet -f graffiti $hostname; echo;echo;
