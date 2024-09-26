#!/bin/bash
set -e

pg_restore db.dump -U $POSTGRES_USER -d $POSTGRES_DB --no-owner --no-acl