Haven Resource 1 image �             �PNG

   IHDR         H-�   tEXtTitle Substanceb�x   +tEXtCreation Time on 19 aug 2015 22:23:45 +0100p�   tIME���   	pHYs  �  ��iTS   gAMA  ���a  �IDATxڭ��OQ�g�v+ݥ���
��"��D0��jb"7�h"�'�^�b�#��Ń�'�BB��@��Z
[Zd�.�� YH��K�M���3�e� ���Ml[P^	�4��ҲZ��j����<䀩c�������i4�e�C�~c.������8u$����57�W������V)Z�~��߅��x��R�^���������p�:5����EFVaV�r�**����f�Q�Kt.����R�M�@��u�O%�1�@�n�pT��qy�U?xE�\��c�* ��@��2��/"��Y�07����;,o �L	����(�Iq�at�̚�@�i��(����ϕ!�5�w�S��Xs���ޑ��qs�?�n�Gd��-%�5� A�EuMē����V��F�e���'@Kdl�o3����4�|g����Vq�S6������=P:�H"/��؋�Z/�Kӯ'�W !݃v#䴼��\� uT�Ҟ��    IEND�B`�tooltip 	   Substancesrc �  Quality.java /* Preprocessed source code */
package haven.res.ui.tt.q.quality;

/* $use: ui/tt/q/qbuff */
import haven.*;
import haven.res.ui.tt.q.qbuff.*;
import java.awt.Color;
import java.awt.image.BufferedImage;
import haven.MenuGrid.Pagina;

/* >tt: Quality */
public class Quality extends QBuff implements GItem.OverlayInfo<Tex> {
    public static boolean show = Utils.getprefb("qtoggle", false);

    public Quality(Owner owner, double q) {
	super(owner, Resource.classres(Quality.class).layer(Resource.imgc, 0).scaled(), "Quality", q);
    }

    public static ItemInfo mkinfo(Owner owner, Object... args) {
	return(new Quality(owner, ((Number)args[1]).doubleValue()));
    }

    public Tex overlay() {
	return(new TexI(GItem.NumberInfo.numrender((int)Math.round(q), new Color(192, 192, 255, 255))));
    }

    public void drawoverlay(GOut g, Tex ol) {
	if(show)
	    g.aimage(ol, new Coord(g.sz().x, 0), 1, 0);
    }
}
code  	  haven.res.ui.tt.q.quality.Quality ����   4 � :
 ; <	 ; =
 > ?
 ; @ A
  C D
  E F
 
 G
  H I	  J
 K L M
  N O P
  Q	  R S
 T U	  V
  W
 T X Y
  Z
  [ \
 ] ^ _ a show Z <init> c Owner InnerClasses (Lhaven/ItemInfo$Owner;D)V Code LineNumberTable mkinfo ;(Lhaven/ItemInfo$Owner;[Ljava/lang/Object;)Lhaven/ItemInfo; overlay ()Lhaven/Tex; drawoverlay (Lhaven/GOut;Lhaven/Tex;)V StackMapTable !(Lhaven/GOut;Ljava/lang/Object;)V ()Ljava/lang/Object; <clinit> ()V 	Signature OverlayInfo ELhaven/res/ui/tt/q/qbuff/QBuff;Lhaven/GItem$OverlayInfo<Lhaven/Tex;>; 
SourceFile Quality.java !haven/res/ui/tt/q/quality/Quality d e f g h i j k l o haven/Resource$Image Image p q Quality # r java/lang/Number s t # ' 
haven/TexI u v w x y java/awt/Color # z { } ~ #  ! " haven/Coord � � � � � # � � � 	haven/Tex . / , - qtoggle � � � haven/res/ui/tt/q/qbuff/QBuff � haven/GItem$OverlayInfo � haven/ItemInfo$Owner haven/Resource classres #(Ljava/lang/Class;)Lhaven/Resource; imgc Ljava/lang/Class; java/lang/Integer valueOf (I)Ljava/lang/Integer; layer � IDLayer =(Ljava/lang/Class;Ljava/lang/Object;)Lhaven/Resource$IDLayer; scaled  ()Ljava/awt/image/BufferedImage; J(Lhaven/ItemInfo$Owner;Ljava/awt/image/BufferedImage;Ljava/lang/String;D)V doubleValue ()D q D java/lang/Math round (D)J (IIII)V haven/GItem$NumberInfo 
NumberInfo 	numrender 1(ILjava/awt/Color;)Ljava/awt/image/BufferedImage; !(Ljava/awt/image/BufferedImage;)V 
haven/GOut sz ()Lhaven/Coord; x I (II)V aimage (Lhaven/Tex;Lhaven/Coord;DD)V haven/Utils getprefb (Ljava/lang/String;Z)Z haven/GItem haven/ItemInfo haven/Resource$IDLayer quality.cjava !       	 ! "     # '  (   :     *+� � � � � � (� 	�    )   
       � * +  (   *     � Y*+2� 
� � �    )         , -  (   > 	    &� Y*� � �� Y � � � �� � � �    )         . /  (   F     � � +,� Y+� � � � �    0     )           A . 1  (   "     
*+,� � �    )       A , 2  (        *� �    )         3 4  (   "      
� � �    )         8    � 5    7 &   *  $ b %	   ` 6	  ; B  m ; n	 O ` |	codeentry :   tt haven.res.ui.tt.q.quality.Quality   ui/tt/q/qbuff   