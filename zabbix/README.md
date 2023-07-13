# Авторегистрация хостов в zabbix-server

В данной работе я поднял 4 инстанса через Terraform, на одну сразу установил zabbix-server.
На остальные 3 установил zabbix-agent, лучше установку делать через ansible, но мне захотелось так. 
После чего зашел через веб-консоль в zabbix, и настроил следуюущее: 
![image](https://github.com/nazarch2000/Portfolio/assets/106932460/daa74a77-64e7-4a27-a192-c4a947238f9d)

Через ansible-playbook на всех 3 агентах сконфигурировал файл zabbix_agentd.conf, после чего все агенты были подключены автоматически к zabbix-server.
![image](https://github.com/nazarch2000/Portfolio/assets/106932460/75283543-c279-449b-9f1c-270da27c2918)

*Я продемонстрировал свои навыки владения такими инструментами как Terraform, Ansible.*
*А также знаю как пользоваться Zabbix'ом. Я создавал собственные UserParameter в Zabbix на python и bash.*
### Bash
![image](https://user-images.githubusercontent.com/106932460/214124139-9ff69111-47a7-45b6-bbe8-f4740c39a11e.png)
![image](https://user-images.githubusercontent.com/106932460/214130313-ab264d0f-5d20-4ba9-8c3e-7e4cc957f9b2.png)
### Python
```python
import sys
import os
import re
import datetime
now = datetime.datetime.now()
if (sys.argv[1] == '-ping'):
        result=os.popen("ping -c 1 " + sys.argv[2]).read()
        result=re.findall(r"time=(.*) ms", result)
        print(result[0])
elif (sys.argv[1] == '1'):
        print("Ryjenko Nazariy")
elif (sys.argv[1] == '2'):
        print(now) # Вывести дату
elif (sys.argv[1] == '-simple_print'): # Если simple_print
        print(sys.argv[2]) # Выводим в консоль содержимое sys.arvg[2]
else: # Во всех остальных случаях
        print(f"unknown input: {sys.argv[1]}") # Выводим непонятый запрос в консоль.
```
![image](https://user-images.githubusercontent.com/106932460/214413137-1507f641-8395-4e06-8f21-aebbaf8fdbb6.png)
