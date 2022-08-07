#!/bin/bash

# Put any tasks you would like to have carried
# out when the container is first created here
echo "ID: $IID, GID: $GGUID, USER:$UUSER"
groupadd -g $GGUID $UUSER
useradd -g $GGUID -u $IID $UUSER

su $UUSER -c "/pgadmin3/bin/pgadmin3"

