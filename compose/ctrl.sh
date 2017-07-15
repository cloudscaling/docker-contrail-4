#!/bin/bash
cmd=`echo $1 | tr "-" "_"`
function cmd_up(){
  docker-compose pull
  docker-compose up -d
}
function cmd_down(){
  docker-compose down
}
case $2 in
  up)
    dc_cmd=cmd_up
    ;;
  down)
    dc_cmd=cmd_down
    ;;
  *)
    echo -e "\n    wrong option
    e.g. ./ctrl.sh contrail-controller up/down"
    exit 1
    ;;
esac
contrail_controller=(database config)
function cmd_contrail_controller(){
  for role in ${contrail_controller[@]}
  do
    cd contrail-controller/$role
    ${dc_cmd}
    cd -
  done
}
function cmd_contrail_analyticsdb(){
  cd contrail-analyticsdb
  ${dc_cmd}
  cd -
}
function cmd_contrail_analytics(){
  cd contrail-analytics
  ${dc_cmd}
  cd -
}
function cmd_all(){
  cmd_contrail_controller
  cmd_contrail_analyticsdb
  cmd_contrail_analytics
}
cmd_${cmd}
