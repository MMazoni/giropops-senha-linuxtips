# Desafio (Day 2) - Descomplicando Docker


- Criar um conta no Docker Hub, caso ainda não possua uma.
- Criar uma conta no Github, caso ainda não possua uma.
- Criar um Dockerfile para criar uma imagem de container para a nossa App
    - O nome da imagem deve ser SEU_USUARIO_NO_DOCKER_HUB/linuxtips-giropops-senhas:1.0
- Fazer o push da imagem para o Docker Hub, essa imagem deve ser pública
- Criar um repo no Github chamado LINUXtips-Giropops-Senhas, esse repo deve ser público
- Fazer o push do cógido da App e o Dockerfile
- Criar um container utilizando a imagem criada
    - O nome do container deve ser giropops-senhas
  - Você precisa deixar o container rodando
- O Redis precisa ser um container


    Dica: Preste atenção no uso de variável de ambiente, precisamos ter a variável REDIS_HOST no container. Use sua criatividade!

## Resolução

Criar uma network para os containers se comunicarem

    docker network create giropops-network

Subir o container do redis

    docker run -p 6379:6379 -itd --net giropops-network --name redis redis

Comando de build da imagem (não precisa, pois estará no DockerHub)

    docker image build -t mmazoni/linuxtips-giropops-senhas:1.0 .

Subir o container da aplicação

    docker run -p 5000:5000 -it --name senhas --net=giropops-network -e REDIS_HOST=redis mmazoni/linuxtips-giropops-senhas:1.0
