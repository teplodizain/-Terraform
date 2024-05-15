# Домашнее задание к занятию "13.Системы мониторинга"

## Обязательные задания

1. Вас пригласили настроить мониторинг на проект. На онбординге вам рассказали, что проект представляет из себя 
платформу для вычислений с выдачей текстовых отчетов, которые сохраняются на диск. Взаимодействие с платформой 
осуществляется по протоколу http. Также вам отметили, что вычисления загружают ЦПУ. Какой минимальный набор метрик вы
выведите в мониторинг и почему?

## Ответ
Четырьмя золотыми сигналами в подходе SRE называются:
Время отклика — время, которое требуется для выполнения запроса.
Величина трафика — величина нагрузки, которая приходится на вашу систему. Для веб — это количество HTTP-запросов, а для потокового аудио — скорость передачи данных
Уровень ошибок — количество или частота неуспешно выполненных запросов. Например, ответ 500 от HTTP-сервера 
Степень загруженности — показатель того, насколько полно загружен ваш сервис. Это мониторинг компонентов, которые покажут загруженность вашего сервиса. Для вычислений —
это ЦПУ, для In-memory БД — RAM

#
2. Менеджер продукта посмотрев на ваши метрики сказал, что ему непонятно что такое RAM/inodes/CPUla. Также он сказал, 
что хочет понимать, насколько мы выполняем свои обязанности перед клиентами и какое качество обслуживания. Что вы 
можете ему предложить?

## Ответ

RAM - оперативная память. Размер оперативной памяти сервера влияет на скорость работы сервера,
т.к. при большом объеме памяти сервер может выполнять больше задач и процессов одновременно.

CPUla - показатель того, на сколько интенсивно нагружен процессор. Значение средней загрузки процессора поможет определить, на сколько процессор справляется с работой. 
Но важно понимать, что каждый случай индивидуален и перед решением о замене процессора на более производительный нужно проанализировать, какие процессы и нагружают процессор и почему.

Inodes - это структуры данных в системах Unix, используемые для хранения информации о файлах и каталогах. 
Так как дескрипторы являются, по сути, данными о данных, их также называют метаданными.

Мы выполняем свои обязанности перед клиентами в полном объеме и качество обслуживания на высоком уровне.

#
3. Вашей DevOps команде в этом году не выделили финансирование на построение системы сбора логов. Разработчики в свою 
очередь хотят видеть все ошибки, которые выдают их приложения. Какое решение вы можете предпринять в этой ситуации, 
чтобы разработчики получали ошибки приложения?

##Ответ
Использовать продуктs с открытым исходным кодом по мониторингу корпоративной инфраструктуры, ELK (Elasticsearch, Logstash, Kibana). 
Использовать локальные журналы или логи на уровне приложений.
Собирать информацию с помощью bash или python скриптов.

#
4. Вы, как опытный SRE, сделали мониторинг, куда вывели отображения выполнения SLA=99% по http кодам ответов. 
Вычисляете этот параметр по следующей формуле: summ_2xx_requests/summ_all_requests. Данный параметр не поднимается выше 
70%, но при этом в вашей системе нет кодов ответа 5xx и 4xx. Где у вас ошибка?

##Ответ
Расчёт SLI может выглядеть таким образом:
SLI = (summ_2xx_requests + summ_3xx_requests) / (summ_all_requests). 

#
5. Опишите основные плюсы и минусы pull и push систем мониторинга.

##Ответ

pull-модели:
Плюсы:

- Ни один внешний клиент не имеет прав на внесение изменений в кластер, все обновления накатываются изнутри.
- Некоторые инструменты также позволяют синхронизировать обновления Helm-чартов и привязывать их к кластеру.
- Docker Registry можно сканировать на наличие новых версий. Если появляется новый образ, Git-репозиторий и deployment обновляются на новую версию.
- Pull-инструменты могут быть распределены по разным пространствам имен с разными репозиториями Git и правами доступа. 
Благодаря этому можно применять мультиарендную (multitenant) модель. 
Например, команда А может использовать пространство имен А, команда В — пространство имен В, а команда, занимающаяся инфраструктурой, может использовать глобальное пространство.
- Как правило, инструменты весьма легковесны.
- В сочетании с такими инструментами, как оператор Bitnami Sealed Secrets, секреты могут храниться в зашифрованном виде в репозитории Git и извлекаться внутри кластера.
- Отсутствует связь с CD-пайплайнами, поскольку развертывания происходят внутри кластера.
Минусы:

- Управлять секретами deployment’ов из Helm-чартов сложнее, чем обычными, поскольку сначала их приходится генерировать в виде, скажем, sealed secrets, затем расшифровывать внутренним оператором и только после этого они становятся доступны для pull-инструмента. 
Затем можно запускать релиз в Helm’е со значениями в уже развернутых секретах. Самый простой способ — создать секрет со всеми значения Helm, используемыми для deployment’а, расшифровать его и закоммитить в Git.
- Применяя pull-подход, вы оказываетесь привязаны к инструментам, оперирующим pull’ами. 
Это ограничивает возможность настройки процесса развертывания deployment’ов в кластере. 
Например, работа с Kustomize осложняется тем, что он должен выполняться до того, как окончательные шаблоны поступают в Git. 

Плюсы push-модели:
Плюсы:

- Безопасность определяется Git-репозиторием и пайплайном сборки.
- Развертывать чарты Helm проще, есть поддержка плагинов Helm.
- Управлять секретами легче, поскольку секреты можно применять в пайплайнах, а также хранить в Git в зашифрованном виде (в зависимости от предпочтений пользователя).
- Отсутствие привязки к конкретному инструменту, поскольку можно использовать любые их типы.
- Обновления версий контейнеров могут быть инициированы пайплайном сборки.
Минусы:

- Данные для доступа к кластеру находятся внутри системы сборки.
- Обновление контейнеров deployment’ов по-прежнему проще проводить с pull-процессом.
- Сильная зависимость от CD-системы.

#
6. Какие из ниже перечисленных систем относятся к push модели, а какие к pull? А может есть гибридные?

##Ответ
push:
- Zabbix
- TICK
- VictoriaMetrics
- Nagios

pull:
- Zabbix
- Prometheus
- VictoriaMetrics
- Nagios

#
7. Склонируйте себе [репозиторий](https://github.com/influxdata/sandbox/tree/master) и запустите TICK-стэк, 
используя технологии docker и docker-compose.

В виде решения на это упражнение приведите скриншот веб-интерфейса ПО chronograf (`http://localhost:8888`). 

P.S.: если при запуске некоторые контейнеры будут падать с ошибкой - проставьте им режим `Z`, например
`./data:/var/lib:Z`

![](https://github.com/teplodizain/-Terraform/blob/main/13.Системы%20мониторинга/images/monitoring_02.png)

![](https://github.com/teplodizain/-Terraform/blob/main/13.Системы%20мониторинга/images/monitoring_01.png)

#
8. Перейдите в веб-интерфейс Chronograf (http://localhost:8888) и откройте вкладку Data explorer.
        
    - Нажмите на кнопку Add a query
    - Изучите вывод интерфейса и выберите БД telegraf.autogen
    - В `measurments` выберите cpu->host->telegraf-getting-started, а в `fields` выберите usage_system. Внизу появится график утилизации cpu.
    - Вверху вы можете увидеть запрос, аналогичный SQL-синтаксису. Поэкспериментируйте с запросом, попробуйте изменить группировку и интервал наблюдений.

Для выполнения задания приведите скриншот с отображением метрик утилизации cpu из веб-интерфейса.
#
9. Изучите список [telegraf inputs](https://github.com/influxdata/telegraf/tree/master/plugins/inputs). 
Добавьте в конфигурацию telegraf следующий плагин - [docker](https://github.com/influxdata/telegraf/tree/master/plugins/inputs/docker):
```
[[inputs.docker]]
  endpoint = "unix:///var/run/docker.sock"
```

Дополнительно вам может потребоваться донастройка контейнера telegraf в `docker-compose.yml` дополнительного volume и 
режима privileged:
```
  telegraf:
    image: telegraf:1.4.0
    privileged: true
    volumes:
      - ./etc/telegraf.conf:/etc/telegraf/telegraf.conf:Z
      - /var/run/docker.sock:/var/run/docker.sock:Z
    links:
      - influxdb
    ports:
      - "8092:8092/udp"
      - "8094:8094"
      - "8125:8125/udp"
```

После настройке перезапустите telegraf, обновите веб интерфейс и приведите скриншотом список `measurments` в 
веб-интерфейсе базы telegraf.autogen . Там должны появиться метрики, связанные с docker.

Факультативно можете изучить какие метрики собирает telegraf после выполнения данного задания.

## Дополнительное задание (со звездочкой*) - необязательно к выполнению

1. Вы устроились на работу в стартап. На данный момент у вас нет возможности развернуть полноценную систему 
мониторинга, и вы решили самостоятельно написать простой python3-скрипт для сбора основных метрик сервера. Вы, как 
опытный системный-администратор, знаете, что системная информация сервера лежит в директории `/proc`. 
Также, вы знаете, что в системе Linux есть  планировщик задач cron, который может запускать задачи по расписанию.

Суммировав все, вы спроектировали приложение, которое:
- является python3 скриптом
- собирает метрики из папки `/proc`
- складывает метрики в файл 'YY-MM-DD-awesome-monitoring.log' в директорию /var/log 
(YY - год, MM - месяц, DD - день)
- каждый сбор метрик складывается в виде json-строки, в виде:
  + timestamp (временная метка, int, unixtimestamp)
  + metric_1 (метрика 1)
  + metric_2 (метрика 2)
  
     ...
     
  + metric_N (метрика N)
  
- сбор метрик происходит каждую 1 минуту по cron-расписанию

Для успешного выполнения задания нужно привести:

а) работающий код python3-скрипта,

б) конфигурацию cron-расписания,

в) пример верно сформированного 'YY-MM-DD-awesome-monitoring.log', имеющий не менее 5 записей,

P.S.: количество собираемых метрик должно быть не менее 4-х.
P.P.S.: по желанию можно себя не ограничивать только сбором метрик из `/proc`.

2. В веб-интерфейсе откройте вкладку `Dashboards`. Попробуйте создать свой dashboard с отображением:

    - утилизации ЦПУ
    - количества использованного RAM
    - утилизации пространства на дисках
    - количество поднятых контейнеров
    - аптайм
    - ...
    - фантазируйте)
    
    ---

### Как оформить ДЗ?

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---

