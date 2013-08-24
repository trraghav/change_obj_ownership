change_ownership.sh
===================

Script will change all objects ownership from x to y in a particular schema. 


Step 1

Before running script you need to set environment variables so that Pg-dump/psql client used in script will connect using these variables.

export PGHOST=localhost PGUSER=postgres PGDATABASE=postgres PGPORT=5432

Step 2

You need to pass two mandatory arguments like NEW USER name ( -n ) and SCHEMA NAME ( -S ).

sh change_owner.sh -n user1 -S xml

Summary:
        Tables/Sequences/Views : 1
        Functions              : 0
        Aggregates             : 0
        Type                   : 0


Any corrections or comments can be sent to ragavendra.dba@gmail.com.

Thank you.
