#!/bin/bash
# Raghavendra Rao, EnterpriseDB
# Script changes all the object ownership from x to y
# Provided following environment variable are
# mandatory PGUSER/PGDATABASE/PGPORT/PGHOST beforehand
#------------------------------------------------------

flag=0
usage()
{
  echo "Usage:"
  echo "       sh change_owner.sh -n new_role -S schema_name_of_objects"
  echo ""
  echo "      -n    Give the new role name for the objects to be owned."
  echo "      -S    Schema in which objects has to be changed."
  echo " "
  echo " Note: Set PGUSER - PGDATABASE - PGPORT - PGHOST - PG binaries in PATH "
  echo -e " ----  before running the script.\n"
  exit 1;
}

if env |grep -q  ^PGPORT= && env | grep -q ^PGUSER= && env | grep -q ^PGDATABASE= && env | grep -q ^PGHOST=
then
   PGDATABASE=`env | grep -i pgdatabase | cut -d "=" -f2`
else
   echo -e "\nScript need PGHOST/PGUSER/PGDATABASE/PGPORT environment variables set... \n"
   usage
fi

if ! command -v psql >/dev/null 2>&1; then
   echo -e "\nPostgreSQL psql client not set in Path..."
   usage
fi
PGSQLBIN=`command -v psql`
DUMPBIN=`command -v pg_dump`

while getopts ":n:S:" options; do
    case $options in
        n)
            flag=$((flag+1))
            NEWROLE=${OPTARG}
            ;;
        S)
            flag=$((flag+1))
            SCHEMAS=${OPTARG}
            ;;
        \?) echo "Unknown option: -$OPTARG" >&2; usage ;exit 1;;
     esac
done

if [ $flag -ne 2 ]; then
   echo -e "\n\t All options are Mandatory...!!!"
   usage
   exit 1
fi

UCHECK=$($PGSQLBIN -t -c "select 1 from pg_authid where rolname = '$NEWROLE';")
SCHECK=$($PGSQLBIN -t -c "select 1 from pg_namespace where nspname = '$SCHEMAS';")
UUCHECK=${UCHECK:-0}
SSCHECK=${SCHECK:-0}
if [ $UUCHECK -eq 1 ] && [ $SSCHECK -eq 1 ];
then
   $DUMPBIN -s -c -U postgres ${PGDATABASE} | egrep "${SCHEMAS}\..*OWNER TO"| sed -e "s/OWNER TO.*;$/OWNER TO ${NEWROLE};/" >/tmp/oc.sql
   $DUMPBIN -s -c -U postgres ${PGDATABASE} | egrep "${SCHEMAS}\..*OWNER TO"| sed -e "s/OWNER TO.*;$/OWNER TO ${NEWROLE};/" \
                  | $PGSQLBIN -U postgres -d ${PGDATABASE} >>/dev/null
                     echo -e "\n Summary: "
   echo "        Tables/Sequences/Views : `grep -i "alter table" /tmp/oc.sql | wc -l`"
   echo "        Functions              : `grep -i "alter function" /tmp/oc.sql | wc -l`"
   echo "        Aggregates             : `grep -i "alter aggregate" /tmp/oc.sql | wc -l`"
   echo "        Type                   : `grep -i "alter type" /tmp/oc.sql | wc -l`"
   echo ""
else
   echo " User ($NEWROLE) or Schema ($SCHEMAS) doesnt exist, pass the valid one..... "
fi
