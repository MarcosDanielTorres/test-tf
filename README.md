<h1 align="center">
  <img src="images/logo.jpg" alt="Skybox Logo" width=200 />
</h1>


## Index
- [**Introduction**](#introduction)
- [**Structure**](#structure)
- [**Getting Started**](#getting-started)
- [**Usage**](#usage)
- [**Design Considerations**](#design-considerations)
- [**Payable Endpoint**](#payable-endpoints)
    - [**Create payable**](#create-payable)
    - [**Unpaid payables**](#unpaid-payables)
- [**Transaction Endpoint**](#transaction-endpoints)
    - [**Create transaction**](#create-transaction)
    - [**Get transactions**](#get-transactions)
- [**Imagenes de ejemplo**](#imagenes-de-ejemplo)
# Introduction
This repository corresponds to the challenge Skybox provided for the DevOps Engineer position.
The cluster has been set up and is being monitored through [Terraform], the [Terraform Provider for Docker], and bash for shell scripting. It can be scaled up horizontally with the help of a Load Balancer implemented through [Nginx], which uses round-robin and weighted round-robin algorithms to route traffic.

## Structure
-  `src/`: This directory includes the source code used to create the "cluster" script. The structure was established by running "bashly init" since the script was developed with its aid.
-  `template/`: In this folder, you'll find templates for creating the load balancer and web services. Once you open it, you'll notice a string that reads "REPLACEME". Keep this in mind as it will be useful when installing the cluster later on.

## Getting Started

1. Install [Terraform].
2. Install [Docker].
3. Clone the project: `git clone https://github.com/MarcosDanielTorres/skybox-challenge`
4. To set up the cluster, simply run the command `./cluster install`. If you wish to specify the number of nodes to deploy, you may do so optionally (the default is 2).
5. After step number 4. If you encounter an error about the docker provider when `terraform apply` is running. You might need to specify the host of the docker provider under:
```
provider "docker"{
  host = "...COMPLETE HERE..."
}
```
It may be useful to run `docker context ls`     

6. Running ./cluster --help gives you a list of all possible commands. But to sum them up:
  -  ./cluster install 4        Installs 4 web services and a load balancer. The load balancer is always included, making a total of 5 containers.
  -  ./cluster stop             The command "stop" will halt all containers currently in operation within the cluster.
  -  ./cluster start            This command will initiate all containers that are currently stopped within the cluster.
  -  ./cluster status           It displays details on the running containers' status.
  -  ./cluster delete           Removes all created resources.
### Optional step:
The `cluster` is a script created using [Bashly]. If you wish to regenerate the script you need to have `bashly` installed. Please refer to the official documentation for details. `bashly generate` creates the script named `cluster`.

## Design Considerations
Some of the design decisions when making the REST API are briefly detailed.

Primero se crearon dos colecciones, una llamada Payable y otra llamada Transaction. Se optó por traducir los atributos de las colecciones al inglés, por lo tanto:
* Payable:
    * Tipo de servicio  -> service
    * Descripción del servicio -> description
    * Fecha de vencimiento -> expiration_date
    * Importe del servicio -> amount
    * Status del pago -> status
    * Código de barra-> barcode

* Transaction:
    * Método de pago -> payment_method
    * Número de la tarjeta -> card_number
    * Importe del pago -> amount_paid
    * Código de barra -> barcode
    * Fecha de pago -> payment_date

Por otro lado, se decidió hacer uso de enumerados en la definición de algunos atributos de los esquemas de las colecciones. Principalmente en service de Payable y payment_method de Transaction. Esto es porque dichos atributos solo pueden contener uno de varios valores predeterminados. En esencia: service es "Gas"o  "Water" o "Electricity" y un payment_method puede ser o "cash", o "debit_card", o "credit_card". Por lo tanto, se vio justificado.

### Bibliotecas utilizadas:
* mongoose
* express
* nodemon
* babel
## Payable endpoints
### Create Payable
---

Crea un nuevo objeto Payable y lo retorna en formato JSON.

- **URL**

  /api/payables/

- **Method:**

  `POST`

- **URL Params**

  None

- **Data Params**

    ```json
    {
      "barcode": "acp-128daz",
      "service": "Gas",
      "description": "Esta es una factura de gas",
      "expiration_date": "2021-11-16T03:00:00.000Z",
      "status": "pending",
      "amount": 322
    }
    ```
- **Success Response:**

  - **Code:** 201 <br />
    **Content:** 
    ```json
    {
      "barcode": "acp-128daz",
      "service": "Gas",
      "description": "Esta es una factura de gas",
      "expiration_date": "2021-11-16T03:00:00.000Z",
      "status": "pending",
      "amount": 322,
      "_id": "61a65f9c321a69c702c44fad"
    }
    ```

- **Error Response:**

  - **Code:** 400 BAD REQUEST <br />
    **Content:** `{ error : "..." }`
    
    
### Unpaid Payables
---

Lista aquellas boletas impagas en forma total o filtradas por tipo de servicio.

- **URL**

  /api/payables/unpaid?service <br>
  service es opcional, pero si se provee un servicio tiene que ser uno válido.
  
- **Method:**

  `GET`

- **URL Params**

  service

- **Data Params**
  None
  
- **Success Response sin proporcionar el service:**

  - **Code:** 201 <br />
    **Content:** 
    ```json
    {
        "service": "Gas",
        "expiration_date": "2021-11-16T03:00:00.000Z",
        "amount": 912.1,
        "barcode": "a8193-123"
    }
    ```
    
- **Success Response proporcionando el service:**

  - **Code:** 201 <br />
    **Content:** 
    ```json
    {
        "expiration_date": "2021-11-16T03:00:00.000Z",
        "amount": 912.1,
        "barcode": "a8193-123"
    }
    ```


- **Error Response:**

  - **Code:** 400 BAD REQUEST <br />
    **Content:** `{ error : "..." }`
    
## Transaction endpoints
### Create Transaction
---

Crea un nuevo objeto Transaction que va a representar un pago de un Payable y lo retorna en formato JSON.

- **URL**

  /api/transactions/

- **Method:**

  `POST`

- **URL Params**

  None

- **Data Params**

    ```json
    {
        "payment_method": "cash",
        "amount_paid": 233,
        "barcode": "zaza",
        "payment_date": "2022-05-20"
    }
    ```
- **Success Response:**

  - **Code:** 201 <br />
    **Content:** 
    ```json
    {
        "payment_method": "cash",
        "payment_date": "2022-05-20T00:00:00.000Z",
        "amount_paid": 233,
        "barcode": "zaza",
        "_id": "61a6658a7a175a43348f0342"
    }
    ```

- **Error Response:**

  - **Code:** 400 BAD REQUEST <br />
    **Content:** `{ error : "..." }`
    
### Get Transactions
---

Lista aquellas transacciones entre un período de fechas, acumulando por día.

- **URL**

  /api/payables/unpaid?initial_date=&final_date= <br>
  debe proporcionarse una fecha inicial y una final para que funcione correctamente.
  
- **Method:**

  `GET`

- **URL Params**

  intial_date y final_date

- **Data Params**
  None
  
    
- **Success Response:**

  - **Code:** 201 <br />
    **Content:** 
    ```json
    [
      {
          "total": 1234.2,
          "number_of_transactions": 2,
          "payment_date": "2021-12-20"
      },
      {
          "total": 913.1,
          "number_of_transactions": 2,
          "payment_date": "2022-05-20"
      }
    ]
    ```


- **Error Response:**

  - **Code:** 400 BAD REQUEST <br />
    **Content:** `{ error : "..." }`

## Imagenes de ejemplo
Por favor, dirigirse a la carpeta `images` donde se encuentran ejemplos de uso de los endpoints explayados anteriormente.




[Terraform]: https://nodejs.org
[Docker]: https://www.docker.com/
[Nginx]: https://www.nginx.com
[Bashly]: https://bashly.dannyb.co
[Terraform Provider for Docker]: https://github.com/kreuzwerker/terraform-provider-docker
