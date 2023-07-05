![image](https://github.com/Rozan312/Cloud-Service-Hunting/assets/49874549/5c78e820-4a69-470b-8b79-3d761f74b8a2)
#                                                     Cloud-Service-Hunting
Cloud Service Hunting is a script that automatically searches for publicly exposed/vulnerable cloud service providers only by combining several open source tools using the bash language. 
# Feature :
- Subdomain Enumeration ([Subfinder](https://github.com/projectdiscovery/subfinder), [AssetFinder](https://github.com/tomnomnom/assetfinder), [Amass](https://github.com/owasp-amass/amass))
- Permutation Domain Cloud ([cloud_enum](https://github.com/initstring/cloud_enum))
- Find Domain Cloud on JavaScript ([Katana](https://github.com/projectdiscovery/katana))
  - Parsing Only Cloud Service Domain
  - Exploitation with nuclei
  - Dorking

## Installation Steps

Before entering the step below. Make sure your Linux has **python3.+ and golang** installed.

1. Clone Cloud Service Hunting From git
```
git clone https://github.com/Rozan312/Cloud-Service-Hunting.git
```
2. Change the directory
```
cd Cloud-Service-Hunting
```
3. Change Permission install.sh & CloudShunting.sh
```
chmod +x install.sh CloudShunting.sh
```
5. Install Dependencies Tools and Custom Script
```
./install.sh
```
6. Done !!!

### Note For Installation
If you already have some of the tools needed in this Cloud Service Hunting script. You can make changes in the CloudShunting.sh or install.sh script file to reduce the impact of the error given.

## How To Use 
* Just run the command
```
./CloudShunting.sh
``` 
#                                                     MindMap
![Cloud Service HuntingV 1](https://github.com/Rozan312/Cloud-Service-Hunting/assets/49874549/70b049cd-7e43-420c-b7af-9ba46b020744)

# NOTE
(This script is still very simple. In the future, it will always be updated in terms of features or output information received.)
