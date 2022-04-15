import java.util.*;

void setup() {
  size(400, 300);
  noLoop();
}

void draw() {
  PImage img = loadImage("C:/Users/Roberto/OneDrive/Documentos/Github/Segmentacao_imagens/dataset/placas/0_0_735.jpg"); /* carrega a imagem */
  PImage aux = createImage(img.width, img.height, RGB);
  String cinza_RGB = "B"; //colocar aqui as cores que vai usar na escala de cinza respeita a sequencia RGB
  //EX: usar somente o vermelho: String cinza_RGB = "R";
  //EX: usar vermelho e azul: String cinza_RGB = "RB";
  //EX: usar vermelhO, verde e azul: String cinza_RGB = "RGB";

  //image(img, 0, 0);
  //save("resultados/1-original.jpg");

  //-----------Aplicar escala de cinza-----------------//
  aux = aplicar_escala_cinza(img, cinza_RGB);
  //image(aux, 0, 0);
  //save("resultados/2-color" + cinza_RGB + "-escalaCinza.jpg");

  /*
  //-----------Aplicar janela deslizante-----------------//
  int janela = 1;
  aux = aplicar_filtro_media_janela_deslizante(img, aux, janela);
  image(aux, 0, 0);
  save("resultados/3-color" + cinza_RGB + "-janela-deslizante.jpg");
  */

  //-----------Aplicar filtro de Gauss-----------------//
  float paramGauss = 1.0361; //Kernel!
  int times_to_apply_gauss = 6; //quantidade de vezes para aplicar filtro de Gauss
  for (int x = 0; x < times_to_apply_gauss; x++) {
    aux = aplicar_filtro_gaussiano(paramGauss, img, aux);
    image(aux, 0, 0);
    save("resultados/4." + x + "-color" + cinza_RGB + "-Gauss.jpg");
  }

  /*
  //-----------deixar em preto e branco-----------------//
   int color_below = 20; //só mostrar cores abaixo disso
   aux = aplicar_filtro_limiarizacao_color_below(img, aux, color_below);
   image(aux, 0, 0);
   save("resultados/5-color" + cinza_RGB + "-limiarizacao.jpg");
   */

  /*
  //-----------Mostrar imagem final--------------------//
   aux = show_final_image(img, aux);
   image(aux, 0, 0);
   save("resultados/6-color" + cinza_RGB + "-imagem_final.jpg");
   */

  //-----------Aplicar filtro de borda-----------------//
  aux = aplicar_filtro_borda(img, aux);
  image(aux, 0, 0);
  save("resultados/7-color" + cinza_RGB + "-borda.jpg");

  aux = pintar_dentro_das_bordas(img, aux);
  image(aux, 0, 0);
  save("resultados/7-color" + cinza_RGB + "-pintar-borda.jpg");
  
  //-----------Mostrar imagem final--------------------//
   aux = show_final_image(img, aux);
   image(aux, 0, 0);
   save("resultados/6-color" + cinza_RGB + "-imagem_final.jpg");
   
  /*
  //salvando valores dos pixels
  List<Integer> px = new ArrayList<>();
  for (int y = 100; y < 101; y++) {
    for (int x = 0; x < img.width; x++) {
      int pos = y * img.width + x;
      px.add(int(red(aux.pixels[pos])));
    }
  }

  //print("Original: ");
  //print(px);
  //print("\n");
  //print(px.get(1));


  //encontrando primeiro
  int pos_inicio = 0;
  float media = 0;
  while (media < 250) {
    media = (px.get(pos_inicio) + px.get(pos_inicio+1))/2;
    pos_inicio++;
  }
  print("Começo da borda " + pos_inicio);
  print("\n");
  
  */
}
//--------------FUNÇÕES-----------

PImage pintar_dentro_das_bordas(PImage img, PImage aux) {
  PImage aux1 = createImage(img.width, img.height, RGB);
  List<Integer> px = new ArrayList<>();

  //salvando valores dos pixels
  for (int y = 0; y < img.height; y++) {

    for (int x = 0; x < img.width; x++) {
      int pos = y * img.width + x;
      px.add(int(red(aux.pixels[pos])));
    }

    //encontrando primeiro
    int pos_inicio = 0;
    float media = 0;
    boolean preto = false;
    while (media < 250) {
      if(pos_inicio >= img.width-1){
        preto = true;
        break;
      }
      media = (px.get(pos_inicio) + px.get(pos_inicio+1))/2;
      pos_inicio++;
    }

    //encontrando ultimo
    int pos_final = img.width-1;
    media = 0;
    while (media < 250 && preto == false) {
      media = (px.get(pos_final) + px.get(pos_final-1))/2;
      pos_final--;
    }

    //pintar dentro e fora das bordas
    for (int x = 0; x < img.width; x++) {
      int pos = y * img.width + x;

      if (x <= pos_inicio || x >= pos_final || preto == true)
        aux1.pixels[pos] = color(0);
      else
        aux1.pixels[pos] = color(255);
    }

    //limpando lista
    px.clear();
  }

  return aux1;
}

//escala de cinza
PImage aplicar_escala_cinza(PImage img, String cinza_RGB) {
  cinza_RGB = cinza_RGB.toUpperCase();
  PImage aux = createImage(img.width, img.height, RGB);
  for (int y = 0; y < img.height; y++) {
    for (int x = 0; x < img.width; x++) {
      int pos = (y)*img.width + (x); /* acessa o ponto em forma de vetor */
      float media;

      switch(cinza_RGB) {
      case "R":
        media = red(img.pixels[pos]);
        aux.pixels[pos] = color(media, media, media);
        break;
      case "G":
        media = green(img.pixels[pos]);
        aux.pixels[pos] = color(media, media, media);
        break;
      case "B":
        media = blue(img.pixels[pos]);
        aux.pixels[pos] = color(media, media, media);
        break;
      case "RG":
        media = (red(img.pixels[pos]) + green(img.pixels[pos])) / 2;
        aux.pixels[pos] = color(media, media, media);
        break;
      case "RB":
        media = (red(img.pixels[pos]) + blue(img.pixels[pos])) / 2;
        aux.pixels[pos] = color(media, media, media);
        break;
      case "GB":
        media = (green(img.pixels[pos]) + blue(img.pixels[pos])) / 2;
        aux.pixels[pos] = color(media, media, media);
        break;
      default:
        media = (red(img.pixels[pos]) + green(img.pixels[pos]) + blue(img.pixels[pos])) / 3;
        aux.pixels[pos] = color(media, media, media);
      }
    }
  }

  return aux;
}

// filtro gauss
float gauss(int x, int y, float param) {
  float valor;
  valor = (1/(2*PI*pow(param, 2)) *
    (exp((-( pow(x, 2) + pow(y, 2))/ 2*pow(param, 2)))));
  return valor;
}

PImage aplicar_filtro_gaussiano(float paramGauss, PImage img, PImage aux) {
  PImage aux1 = createImage(img.width, img.height, RGB);
  float[][] gx = {{gauss(-1, -1, paramGauss), gauss(0, -1, paramGauss), gauss(1, -1, paramGauss)},
    {gauss(-1, 0, paramGauss), gauss(0, 0, paramGauss), gauss(1, 0, paramGauss)},
    {gauss(-1, 1, paramGauss), gauss(0, 1, paramGauss), gauss(1, 1, paramGauss)}};

  float[][] gy = {{gauss(-1, -1, paramGauss), gauss(0, -1, paramGauss), gauss(1, -1, paramGauss)},
    {gauss(-1, 0, paramGauss), gauss(0, 0, paramGauss), gauss(1, 0, paramGauss)},
    {gauss(-1, 1, paramGauss), gauss(0, 1, paramGauss), gauss(1, 1, paramGauss)}};

  // Filtro Gaussiano
  for (int y = 0; y < img.height; y++) {
    for (int x = 0; x < img.width; x++) {
      int jan = 1;
      int pos = (y)*img.width + (x); /* acessa o ponto em forma de vetor */

      float mediaOx = 0, mediaOy = 0;

      // janela tamanho 1
      for (int i = jan*(-1); i <= jan; i++) {
        for (int j = jan*(-1); j <= jan; j++) {
          int disy = y+i;
          int disx = x+j;
          if (disy >= 0 && disy < img.height &&
            disx >= 0 && disx < img.width) {
            int pos_aux = disy * img.width + disx;
            float Ox = red(aux.pixels[pos_aux]) * gx[i+1][j+1];
            float Oy = red(aux.pixels[pos_aux]) * gy[i+1][j+1];
            mediaOx += Ox;
            mediaOy += Oy;
          }
        }
      }

      // Raiz da soma ao quadrado
      float mediaFinal = sqrt(mediaOx*mediaOx + mediaOy*mediaOy);

      //Absoluto de cada e soma
      //float mediaFinal = abs(mediaOx) + abs(mediaOy);

      // Absoluto da soma geral
      //float mediaFinal = abs(mediaOx + mediaOy);

      // Soma
      //float mediaFinal = mediaOx + mediaOy;

      // Multiplicação
      //float mediaFinal = mediaOx * mediaOy;

      aux1.pixels[pos] = color(mediaFinal);
    }
  }

  return aux1;
}


PImage aplicar_filtro_media_janela_deslizante(PImage img, PImage aux, int janela) {
  PImage aux1 = createImage(img.width, img.height, RGB);
  //filtro de média com janela deslizante
  for (int y=0; y < img.height; y++)
  {
    for (int x=0; x < img.width; x++)
    {
      int pos = y * img.width + x;
      int jan = janela, qtde = 0; //modificar o valor jan deixa a imagem mais embasada
      float media = 0;

      //i = altura, j= largura
      //criando matriz interna para calcular a média
      for (int i = jan*(-1); i<= jan; i++) {
        for (int j = jan*(-1); j <= jan; j++) {
          int nx = x + j;
          int ny = y + i;

          if (ny >= 0 && ny < aux.height && nx >= 0 && nx < aux.width) {

            int pos_aux = ny * aux.width + nx;
            media += red(img.pixels[pos_aux]); // tanto faz red(), green() ou blue() pois está na escala de cinza
            qtde++;
          }
        }
      }

      media = media / qtde;
      aux1.pixels[pos] = color(media);
    }
  }

  return aux1;
}

//filtro de limiarização
PImage aplicar_filtro_limiarizacao_color_above(PImage img, PImage aux2, int color_above) {
  PImage aux1 = createImage(img.width, img.height, RGB);
  for (int y=0; y < img.height; y++)
  {
    for (int x=0; x < img.width; x++)
    {
      int pos = y * img.width + x;
      if (red(aux2.pixels[pos]) > color_above)
        aux1.pixels[pos] = color(255);
      else
        aux1.pixels[pos] = color(0);
    }
  }

  return aux1;
}

//filtro de limiarização
PImage aplicar_filtro_limiarizacao_color_below(PImage img, PImage aux2, int color_below) {
  PImage aux1 = createImage(img.width, img.height, RGB);
  for (int y=0; y < img.height; y++)
  {
    for (int x=0; x < img.width; x++)
    {
      int pos = y * img.width + x;
      if (red(aux2.pixels[pos]) < color_below)
        aux1.pixels[pos] = color(255);
      else
        aux1.pixels[pos] = color(0);
    }
  }

  return aux1;
}

//mostrar a imagem final
PImage show_final_image(PImage img, PImage aux2) {
  PImage aux1 = createImage(img.width, img.height, RGB);
  for (int y=0; y < img.height; y++)
  {
    for (int x=0; x < img.width; x++)
    {
      int pos = y * img.width + x;

      if (blue(aux2.pixels[pos]) == 255)
      {
        aux1.pixels[pos] = img.pixels[pos];
      }
    }
  }

  return aux1;
}

// Filtro de borda
PImage aplicar_filtro_borda(PImage img, PImage aux) {
  PImage aux1 = createImage(img.width, img.height, RGB);
  //Kernel (declarando e atribuindo valor)
  int[][] gx = {{-1, -2, -1}, {0, 0, 0}, {1, 2, 1}};
  int[][] gy = {{-1, 0, 1}, {-2, 0, 2}, {-1, 0, 1}};

  // Filtro de Borda - Sobel
  for (int y = 0; y < img.height; y++) {
    for (int x = 0; x < img.width; x++) {
      int jan = 1;
      int pos = (y)*img.width + (x); /* acessa o ponto em forma de vetor */

      float mediaOx = 0, mediaOy = 0;

      // janela tamanho 1
      for (int i = jan*(-1); i <= jan; i++) {
        for (int j = jan*(-1); j <= jan; j++) {
          int disy = y+i;
          int disx = x+j;
          if (disy >= 0 && disy < img.height &&
            disx >= 0 && disx < img.width) {
            int pos_aux = disy * img.width + disx;
            float Ox = red(aux.pixels[pos_aux]) * gx[i+1][j+1];
            float Oy = red(aux.pixels[pos_aux]) * gy[i+1][j+1];
            mediaOx += Ox;
            mediaOy += Oy;
          }
        }
      }

      // Raiz da soma ao quadrado
      float mediaFinal = sqrt(mediaOx*mediaOx + mediaOy*mediaOy);

      //Absoluto de cada e soma
      //float mediaFinal = abs(mediaOx) + abs(mediaOy);

      // Absoluto da soma geral
      //float mediaFinal = abs(mediaOx + mediaOy);

      // Soma
      //float mediaFinal = mediaOx + mediaOy;

      // Multiplicação
      //float mediaFinal = mediaOx * mediaOy;

      // Limiarização e setar
      if (mediaFinal > 255) mediaFinal = 255;
      if (mediaFinal < 0) mediaFinal = 0;

      aux1.pixels[pos] = color(mediaFinal);
    }
  }

  return aux1;
}
