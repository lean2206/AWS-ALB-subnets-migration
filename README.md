# AWS ALB subnets migration

Este script en Bash se utiliza para facilitar la migración de subnets asociadas a balanceadores de carga en Amazon Web Services (AWS). El script interactúa con la AWS Command Line Interface (CLI) para realizar operaciones en balanceadores de carga y subnets.

## Requisitos Previos
Antes de ejecutar este script, asegúrate de que cumplas con los siguientes requisitos:

1) Tener la AWS CLI instalada y configurada con las credenciales adecuadas.
2) Conocer las subnets que deseas migrar y las subnets actuales asociadas al balanceador de carga.
3) Tener los permisos necesarios para interactuar con los recursos de AWS especificados.

## Uso del Script
El script se encarga de asociar nuevas subnets a un balanceador de carga y, opcionalmente, permite realizar un rollback en caso de ser necesario.

1) **Variables:** Al inicio del script, hay una sección donde puedes definir las variables necesarias para la ejecución del mismo:

  - VPC_ID: La ID de la VPC en la que se encuentra el balanceador de carga y las subnets.
  - NEW_SUBNETS: Un arreglo que contiene las IDs de las nuevas subnets que deseas asociar.
  - ACTUAL_SUBNETS: Un arreglo que contiene las IDs de las subnets actuales asociadas al balanceador de carga.

2) **Función get_alb_arn():** Esta función toma el nombre de un balanceador de carga como argumento y devuelve el ARN (Amazon Resource Name) correspondiente a ese balanceador de carga en la VPC especificada.

3) **Bucle Infinito:** El script contiene un bucle infinito (while true) para permitir múltiples migraciones sin necesidad de reiniciar el script.
El bucle guía al usuario a través de los siguientes pasos:
  - Seleccionar un balanceador de carga de una lista predefinida.4
  - Especificar la cantidad de nuevas subnets que deseas migrar.
  - Asociar las nuevas subnets al balanceador de carga.
  - Preguntar si se desea realizar un rollback en caso de problemas.

## Ejecución del Script

1) Asegúrate de que el script tenga permisos de ejecución. Si no los tiene, puedes otorgarlos con el comando:

<pre>
chmod +x alb-subnet-mig.sh
</pre>
3) Ejecuta el script:
<pre>
./alb-subnet-mig.sh
</pre>

Sigue las instrucciones en pantalla para seleccionar el balanceador de carga, la cantidad de subnets a migrar y si deseas realizar un rollback.
