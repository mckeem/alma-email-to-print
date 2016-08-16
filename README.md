# Alma-Email-to-Print
A small set of scripts to facilitate an Email to Print gateway for the ALMA Library service.

Please fell free to fork these scripts and make them work for you. I would love to here your feedback. 

# Requirements

* Linux server (We use CentOS, pick what suits you)
* [EXIM](http://www.exim.org/) (Or an MTA of your choice)
* [Procmail](http://userpages.umbc.edu/~ian/procmail.html) (Mail Delivery Agent)
* [HTML2PS](http://user.it.uu.se/~jan/html2ps.html) (Convert HTML to PostScript for printing)
* [Mhonarc](https://www.mhonarc.org/) (A Perl email to HTML converter)
* [Git](https://git-scm.com/) (Disributed Version Control Sytem)
* [CUPS](https://www.google.co.uk/url?sa=t&rct=j&q=&esrc=s&source=web&cd=3&cad=rja&uact=8&sqi=2&ved=0ahUKEwi6sN7y0cXOAhVrIsAKHZ6XD5AQFggkMAI&url=https%3A%2F%2Fwww.cups.org%2F&usg=AFQjCNEr3o3-JfsxZQBWGkamM5S_KmAlpQ&sig2=rGBlEDTdZID87X17LBemkg&bvm=bv.129759880,d.ZGg) (Printing system for Linux)

# Installation

This document will not cover the installation and configuration of your MTA, it is out of scope due to the multitude of different configuration options.

This document is aimed towards CentOS 7, depending on your Linux distro of choice you may need to change the installation method below. For example, in Debian you will need to use *apt-get* instead of *yum*

Run an update

```
sudo yum update
```

Install applications

```
sudo yum install procmail html2ps mhonarc cups git
```

Ensure that CUPS and EXIM are running

```
sudo service cups start
sudo service exim start
```

# Setup

As we have multiple libraries and a single printer in each library, I chose to name each user account and printer the same. This allowed me to write a single script that does not need to be modified when deploying.

For example, if we have a printer called *_library1_* in Library1, I would do the following;

```
sudo -s
useradd library1
cd /home/library1
git clone https://github.com/mckeem/alma-email-to-print.git .
lpadmin -p library1 -v lpd://<printer ip/dns name> -o printer-error-policy=retry-job -E
```

As you can see from the above, the user account and printer name are the same. This allows the use of `whoami` in the .procmailrc, making it easier to deploy. 

# Automating User and Printer creation

I have included a script for automating the creation of users and printers, add_printers.sh. add_printers.sh accepts a comma separated file (add_printers.csv) of printer names and IP address and will fully automate the creation of users and printers and deploy the .procmailrc script into each users home directory.

The reverse is also available with del_printers.sh

To set this up, follow the direction below.

```
sudo -s
mkdir /usr/local/bin/ALMA-Deployment 
cd /usr/local/bin/ALMA-Deployment
git clone https://github.com/mckeem/alma-email-to-print.git .
```

You can use any other deployment tool you like, Ansible, Puppet, Chef etc. 

Now create and edit add_printers.csv

``` 
vi add_printers.csv
```

No need for coumn headers, just add your printer names and IP addresses separated by commas

```
library1,10.100.1.1
library2,10.100.1.2
library3,10.100.1.3
```

Now run the add_printers.sh script

*Please note*: Printers are added via LPD rather than IPP. LPD is older, and while it may not provide much control over print settings per job, it does get the job done. If you require authentication and per job settings then I would recommend modifying add_printers.sh to suit your needs. 

```
./add_printers.sh
```

# License

This code is licensed under the MIT License.