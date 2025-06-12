# The DSPS database
The Data Science Professionals Society (DSPS) is a professional organization dedicated to advancing the interests of data scientists. DSPS offers two categories of membership: student and accredited. To transition from student to accredited membership, individuals must hold a degree from a recognized university and successfully complete a series of examinations administered by the society. 

After the examinations are conducted, DSPS's examiners assign grades to the submitted exams, and these results are made available on the society's website. If a student opts to withdraw from DSPS, all their exam entries are nullified. A dedicated database stores information regarding examinations, student members, and exam entries. This database is accessible via the Internet and by DSPS office personnel through available workstations.

DSPS's database contains 4 tables:

 - **exam** (excode, extitle, exlocation, exdate, extime) 

 - **student** (sno, sname, semail)

 - **entry** (eno, excode, sno, egrade)

 - **cancel** (eno, excode, sno, cdate, cuser)

The **exam** table holds details of each examination scheduled for the coming year.

The **student** table holds details of student members of the society.

The **entry** table holds details of the examination entries made by students for the coming year. 

The **cancel** table is used to record details of all entries that have been cancelled.

This repository contains 2 PostgreSQL scripts:

**table_definition**: contains schema and table creation scripts, and triggers to check conditions on insertion/ automatically update the **cancel** table when there is deletion.

**table_queries**: contains the queries to select data (with specific conditions) from, insert/update data into, or delete data from the database tables.
