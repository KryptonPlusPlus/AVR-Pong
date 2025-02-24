<div align="center">

# AVR Pong
</div>

## 💻 Sobre o projeto

Jogo Pong de um jogador em um microcontrolador avr (atmega328pa) exibindo a imagem em um monitor vga de resolução 640x480 60Hz de tela visível.

# :scroll: Sumário

- [Funcionalidades](#⚙️-Funcionalidades)
- [Imagens](#🎨-Imagens)

## ⚙️ Funcionalidades

- [ ] Colisão com os paddles.
    - [x] Tratar a colisão do eixo x.
    - [ ] Alterar a direção e/ou inclinação do eixo y da bola no momento da colisão com o paddle.
- [x] Aceleração da bola ao decorrer do jogo.
- [x] Reiniciar o jogo após errar a bola e apertar um botão.
- [ ] Pontuação dos jogadores.
- [ ] Som.
- [ ] Switch para realizar configurações internas.
- [ ] Indutor e capacitor no _AVCC_ para reduzir ruídos (pag. 213 do datasheet)

## 🎨 Imagens

<details>

<summary>Imagens da montagem do circuito na protoboard:</summary>

<p align="center">
    <img src=".github/protoboard_2.jpeg" width="45%" hspace="10" alt="protoboard 1" title="protoboard 1" >
    <img src=".github/protoboard_1.jpeg" width="45%" hspace="10" alt="protoboard 2" title="protoboard 2" >
</p>

> [!NOTE]
> O _trimpot_ foi utilizado para movimentar o _paddle_ do jogador.

</details>

<details>

<summary>Imagem da renderização da tela no monitor vga:</summary>

<p align="center">
    <img src=".github/screen_image.jpeg" width="90%" alt="monitor" title="monitor">
</p>

> [!NOTE]
> Na imagem da renderização da tela existe uma linha vertical que não aparece, pois foi feita uma centralização da imagem pelas configurações no monitor, proveniente do fato da transferência dos dados das cores ser feita utilizando o _USART_ no modo _Master SPI_, já que quando ele está inativo possui nível lógico alto.

</details>

<details>

<summary>Imagem do esquemático:</summary>
<p align="center">
    <img src=".github/schematic.svg" width="90%" alt="monitor" title="monitor">
</p>

</details>