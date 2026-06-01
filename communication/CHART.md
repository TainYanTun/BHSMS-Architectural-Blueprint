```plantuml
@startuml
top to bottom direction

' Top Level
rectangle "NGO Board of Directors" as Board
rectangle "Executive Director (ED)" as ED
Board --> ED

' CFO Branch
rectangle "Chief Finance Officer (CFO)" as CFO
ED --> CFO

rectangle "Cashier" as Cashier
rectangle "Accountant" as Accountant
rectangle "Chaplain" as Chaplain
rectangle "Purchasing Manager" as PM
rectangle "Driver" as Driver
rectangle "Nurse Assistants" as NurseA
rectangle "Secretary (Finance)" as SecF
rectangle "Security Guards" as Guards
rectangle "Farm, Garden Supervisor" as FarmSup
rectangle "Dairyman" as Dairyman

CFO --> Cashier
CFO --> Accountant
CFO --> Chaplain
CFO --> PM
CFO --> Driver
CFO --> NurseA
PM --> SecF
SecF --> Guards
PM --> FarmSup
FarmSup --> Dairyman

' Maintenance + Operations
rectangle "Maintenance Manager" as MM
rectangle "Asst to Main Man" as AsstMM
rectangle "Handicrafts Workers" as HW
rectangle "Sewing Center" as SC

ED --> MM
MM --> AsstMM
MM --> HW
MM --> SC

' Receiving Center
rectangle "Receiving Center Supervisor" as RCS
rectangle "RC Assistant Supervisor" as RCAS
rectangle "Caregivers" as Care
rectangle "Cleaning Workers" as Clean
rectangle "Laundry Women" as Laundry

MM --> RCS
RCS --> RCAS
RCAS --> Care
RCAS --> Clean
RCAS --> Laundry

' Kitchen
rectangle "Kitchen / Cafeteria Supervisor" as KCS
rectangle "Kitchen Workers" as KW

MM --> KCS
KCS --> KW

' Office + School
rectangle "Office Secretary" as OfficeSec
rectangle "Principal" as Principal
rectangle "Secretary (School)" as SecS
rectangle "BH Teachers" as Teachers

ED --> OfficeSec
OfficeSec --> Principal
Principal --> SecS
Principal --> Teachers

' Sponsorship Director
rectangle "Sponsorship Director (SPD)" as SPD
ED --> SPD

rectangle "Students Boarding Schools" as SBS
rectangle "Secretary (SPD)" as SPDsec
rectangle "Nursing Students" as NS
rectangle "BCI Students" as BCI

SPD --> SBS
SPD --> SPDsec
SPD --> NS
SPD --> BCI

' Education Director
rectangle "Education Director" as EduDir
ED --> EduDir

rectangle "Feeding Schools Supervisor" as FSS
rectangle "Feeding Schools Teachers" as FST

EduDir --> FSS
FSS --> FST

@enduml
```