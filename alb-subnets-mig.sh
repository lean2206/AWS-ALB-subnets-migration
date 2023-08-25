#!/bin/bash

if ! command -v aws &> /dev/null; then
    echo "AWS CLI no está instalado. Instálalo y configúralo correctamente."
    exit 1
fi

# Variables
VPC_ID=""

# Obtener los nombres de los balanceadores en la VPC definida
ALB_NAMES=($(aws elbv2 describe-load-balancers \
    --query "LoadBalancers[?VpcId=='$VPC_ID'].LoadBalancerName" \
    --output text))

NEW_SUBNETS=("subnet-1" "subnet-2" "subnet-3") #REEMPLAZAR CON SUBNETS A MIGRAR

ACTUAL_SUBNETS=("subnet-1" "subnet-2" "subnet-3") #REEMPLAZAR CON SUBNETS ACTUALES DEL BALANCEADOR


#Función para obtener el ARN del balanceador
get_alb_arn() {
  ALB_NAME=$1
  ALB_ARN=$(aws elbv2 describe-load-balancers \
    --query "LoadBalancers[?VpcId=='$VPC_ID' && LoadBalancerName=='$ALB_NAME'].LoadBalancerArn" \
    --output text)
  echo $ALB_ARN
}

while true; do #Bucle infinito. Finalizar con Ctrl + C

  # Mostrar las opciones de ALB_NAME
  echo "Selecciona una opción para ALB_NAME:"
  for ((i=0; i<${#ALB_NAMES[@]}; i++)); do
    echo "$(($i+1)). ${ALB_NAMES[$i]}"
  done

  # Leer la elección del usuario
  read -p "Ingresa el número de la opción deseada: " CHOICE_INDEX

  # Validar la elección del usuario
  if [[ "$CHOICE_INDEX" -ge 1 && "$CHOICE_INDEX" -le ${#ALB_NAMES[@]} ]]; then
    CHOSEN_ALB_NAME=${ALB_NAMES[$CHOICE_INDEX-1]}
  else
    echo "Opción no válida. Saliendo..."
    exit 1
  fi

  ALB_ARN=$(get_alb_arn $CHOSEN_ALB_NAME)

  echo "Balanceador elegido: $CHOSEN_ALB_NAME"
  echo ""


  # Preguntar por la cantidad de subnets a migrar
  NUM_NEW_SUBNETS=${#NEW_SUBNETS[@]}
  read -p "¿Cuántas subnets deseas migrar? (1-$NUM_NEW_SUBNETS): " NUM_SUBNETS

  if [ "$NUM_SUBNETS" -lt 1 ] || [ "$NUM_SUBNETS" -gt "$NUM_NEW_SUBNETS" ]; then
    echo "Cantidad no válida de subnets. Saliendo..."
    exit 1
  fi

  # Obtener las subnets para la migración
  SUBNETS=("${NEW_SUBNETS[@]:0:$NUM_SUBNETS}")


  # Step 4: Asociar nuevas subnets al balanceador
  echo "Asociando nuevas subnets al balanceador"
  aws elbv2 set-subnets --load-balancer-arn $ALB_ARN --subnets $(echo ${SUBNETS[@]}) --output table


  # Step 5: Preguntar por el rollback
  read -p "¿Deseas realizar un rollback de la migración? (si/no): " ROLLBACK

  if [ "$ROLLBACK" = "si" ]; then
    echo "Realizando rollback..."

    # Obtener las subnets para el rollback
    ROLLBACK_SUBNETS=("${ACTUAL_SUBNETS[@]:0:$NUM_SUBNETS}")

    aws elbv2 set-subnets --load-balancer-arn $ALB_ARN --subnets $(echo ${ROLLBACK_SUBNETS[@]}) --output table
    
    echo "Rollback completado"
  else
    echo "Operación completada exitosamente"
  fi
  
  echo "-----------------------------------------------------------____"
  echo ""

done
