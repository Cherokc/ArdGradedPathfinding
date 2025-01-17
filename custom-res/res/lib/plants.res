Haven Resource 1	 src �  GrowingPlant.java /* Preprocessed source code */
package haven.res.lib.plants;

import haven.*;
import haven.resutil.*;
import java.util.*;

public class GrowingPlant implements Sprite.Factory {
    public final int num;

    public GrowingPlant(int num) {
	this.num = num;
    }

    public GrowingPlant(Object[] args) {
	this(((Number)args[0]).intValue());
    }

    public Sprite create(Sprite.Owner owner, Resource res, Message sdt) {
	int st = sdt.uint8();
	ArrayList<FastMesh.MeshRes> var = new ArrayList<FastMesh.MeshRes>();
	for(FastMesh.MeshRes mr : res.layers(FastMesh.MeshRes.class)) {
	    if((mr.id / 10) == st)
		var.add(mr);
	}
	if(var.size() < 1)
	    throw(new Sprite.ResourceException("No variants for grow stage " + st, res));
	Random rnd = owner.mkrandoom();
	CSprite spr = new CSprite(owner, res);
	for(int i = 0; i < num; i++) {
	    FastMesh.MeshRes v = var.get(rnd.nextInt(var.size()));
	    if(num > 1)
		spr.addpart((rnd.nextFloat() * 11f) - 5.5f, (rnd.nextFloat() * 11f) - 5.5f, v.mat.get(), v.m);
	    else
		spr.addpart((rnd.nextFloat() * 4.4f) - 2.2f, (rnd.nextFloat() * 4.4f) - 2.2f, v.mat.get(), v.m);
	}
	return(spr);
    }
}

src   GaussianPlant.java /* Preprocessed source code */
package haven.res.lib.plants;

import haven.*;
import haven.resutil.*;
import java.util.*;

public class GaussianPlant implements Sprite.Factory {
    public final int numl, numh;
    public final float r;

    public GaussianPlant(int numl, int numh, float r) {
	this.numl = numl;
	this.numh = numh;
	this.r = r;
    }

    public GaussianPlant(Object[] args) {
	this(((Number)args[0]).intValue(), ((Number)args[1]).intValue(), ((Number)args[2]).floatValue());
    }

    public Sprite create(Sprite.Owner owner, Resource res, Message sdt) {
	ArrayList<FastMesh.MeshRes> var = new ArrayList<FastMesh.MeshRes>(res.layers(FastMesh.MeshRes.class));
	Random rnd = owner.mkrandoom();
	CSprite spr = new CSprite(owner, res);
	int num = rnd.nextInt(numh - numl + 1) + numl;
	for(int i = 0; i < num; i++) {
	    FastMesh.MeshRes v = var.get(rnd.nextInt(var.size()));
	    spr.addpart((float)rnd.nextGaussian() * r, (float)rnd.nextGaussian() * r, v.mat.get(), v.m);
	}
	return(spr);
    }
}

src �  TrellisPlant.java /* Preprocessed source code */
package haven.res.lib.plants;

import haven.*;
import haven.resutil.*;
import java.util.*;

public class TrellisPlant implements Sprite.Factory {
    public final int num;

    public TrellisPlant(int num) {
	this.num = num;
    }

    public TrellisPlant() {
	this(2);
    }

    public TrellisPlant(Object[] args) {
	this(((Number)args[0]).intValue());
    }

    public Sprite create(Sprite.Owner owner, Resource res, Message sdt) {
	double a = ((Gob)owner).a;
	float ac = (float)Math.cos(a), as = -(float)Math.sin(a);
	int st = sdt.uint8();
	ArrayList<FastMesh.MeshRes> var = new ArrayList<FastMesh.MeshRes>();
	for(FastMesh.MeshRes mr : res.layers(FastMesh.MeshRes.class)) {
	    if((mr.id / 10) == st)
		var.add(mr);
	}
	if(var.size() < 1)
	    throw(new Sprite.ResourceException("No variants for grow stage " + st, res));
	Random rnd = owner.mkrandoom();
	CSprite spr = new CSprite(owner, res);
	float d = 11f / num;
	float c = -5.5f + (d / 2);
	for(int i = 0; i < num; i++) {
	    FastMesh.MeshRes v = var.get(rnd.nextInt(var.size()));
	    spr.addpart(c * as, c * ac, v.mat.get(), v.m);
	    c += d;
	}
	return(spr);
    }
}
code �	  haven.res.lib.plants.GrowingPlant ����   4 �
 ( >	 ' ? @
  A
 ' B
 C D E
  > G
 I J K L M N M O	 	 P
  Q
  R T V
  > W
  X
  Y
  Z
  [ 2 \ ]
  ^
 _ `
  a
 _ bA0  @�  	 	 c
 d e	 	 f
  g@���@�� h i j num I <init> (I)V Code LineNumberTable ([Ljava/lang/Object;)V create l Owner InnerClasses C(Lhaven/Sprite$Owner;Lhaven/Resource;Lhaven/Message;)Lhaven/Sprite; StackMapTable E m n ] G 
SourceFile GrowingPlant.java , o * + java/lang/Number p q , - r s q java/util/ArrayList t haven/FastMesh$MeshRes MeshRes u v w x y z m { | } ~  + � � � q � haven/Sprite$ResourceException ResourceException java/lang/StringBuilder No variants for grow stage  � � � � � � , � � � haven/resutil/CSprite , � n � � � � � � � � � � � � � � � !haven/res/lib/plants/GrowingPlant java/lang/Object haven/Sprite$Factory Factory haven/Sprite$Owner java/util/Iterator java/util/Random ()V intValue ()I haven/Message uint8 haven/FastMesh haven/Resource layers )(Ljava/lang/Class;)Ljava/util/Collection; java/util/Collection iterator ()Ljava/util/Iterator; hasNext ()Z next ()Ljava/lang/Object; id add (Ljava/lang/Object;)Z size haven/Sprite append -(Ljava/lang/String;)Ljava/lang/StringBuilder; (I)Ljava/lang/StringBuilder; toString ()Ljava/lang/String; %(Ljava/lang/String;Lhaven/Resource;)V 	mkrandoom ()Ljava/util/Random; '(Lhaven/Sprite$Owner;Lhaven/Resource;)V nextInt (I)I get (I)Ljava/lang/Object; 	nextFloat ()F mat Res Lhaven/Material$Res; � haven/Material$Res ()Lhaven/Material; m Lhaven/FastMesh; addpart � Op � Node 9(FFLhaven/render/Pipe$Op;Lhaven/render/RenderTree$Node;)V haven/Material � haven/render/Pipe$Op � haven/render/RenderTree$Node haven/render/Pipe haven/render/RenderTree plants.cjava ! ' (  )   * +     , -  .   *     
*� *� �    /       
   	   , 0  .   *     *+2� � � �    /   
        1 5  .  �  
  -� 6� Y� :,	� 
�  :�  � '�  � 	:� 
l� � W���� �  � Y� Y� � � � ,� �+�  :� Y+,� :6*� � x� � � � 	:	*� � .� j f� j f	� !� "	� #� $� +� %j&f� %j&f	� !� "	� #� $�����    6   ' �  7 8*� %�  9 :� O ;� '�  /   F         2  ?  G  J  S  p  x  �  �  �  �   � " �  $  <    � 4   :  2 S 3	 	 F H 	  S U 	 ) S k	 d � � 	 � � �	 � � �	code �  haven.res.lib.plants.GaussianPlant ����   4 �
  4	  5	  6	  7 8
  9
  :
  ; < >
 @ A
 	 B & C D
  E
 F G
 	 H
 	 I
 F J	 
 K
 L M	 
 N
  O P Q S numl I numh r F <init> (IIF)V Code LineNumberTable ([Ljava/lang/Object;)V create U Owner InnerClasses C(Lhaven/Sprite$Owner;Lhaven/Resource;Lhaven/Message;)Lhaven/Sprite; StackMapTable P U V W < X D 
SourceFile GaussianPlant.java   Y       java/lang/Number Z [ \ ]   ! java/util/ArrayList ^ haven/FastMesh$MeshRes MeshRes V _ `   a b c haven/resutil/CSprite   d X e f g [ h i j k l n p h q r s t y "haven/res/lib/plants/GaussianPlant java/lang/Object z haven/Sprite$Factory Factory haven/Sprite$Owner haven/Resource haven/Message java/util/Random ()V intValue ()I 
floatValue ()F haven/FastMesh layers )(Ljava/lang/Class;)Ljava/util/Collection; (Ljava/util/Collection;)V 	mkrandoom ()Ljava/util/Random; '(Lhaven/Sprite$Owner;Lhaven/Resource;)V nextInt (I)I size get (I)Ljava/lang/Object; nextGaussian ()D mat Res Lhaven/Material$Res; { haven/Material$Res ()Lhaven/Material; m Lhaven/FastMesh; addpart } Op  Node 9(FFLhaven/render/Pipe$Op;Lhaven/render/RenderTree$Node;)V haven/Sprite haven/Material � haven/render/Pipe$Op � haven/render/RenderTree$Node haven/render/Pipe haven/render/RenderTree plants.cjava !                         !  "   <     *� *� *� *%� �    #       ,  - 	 .  /  0    $  "   <      *+2� � +2� � +2� � � �    #   
    3  4  % )  "   �  
   �� 	Y,
� � :+�  :� Y+,� :*� *� d`� *� `66� E� � � � 
:	� �*� j� �*� j	� � 	� � �����    *   # � < 	 + , - . / 0 1  � H #   & 	   7  8  9 " : 9 ; C < W =  ; � ?  2    � (   2  & R '	 
 = ? 	  R T	 L o m 	 u | v	 w ~ x	code s
  haven.res.lib.plants.TrellisPlant ����   4 �
 ) C	 ( D
 ( E F
  G H	  I
 J K
 J L
 M N O
  C Q
 S T U V W X W Y	  Z
  [
  \ ^ `
  C a
  b
  c
  d
  e 4 f g
  hA0  ��  
 i j
  k	  l
 m n	  o
  p q r s num I <init> (I)V Code LineNumberTable ()V ([Ljava/lang/Object;)V create u Owner InnerClasses C(Lhaven/Sprite$Owner;Lhaven/Resource;Lhaven/Message;)Lhaven/Sprite; StackMapTable q u v w O x y g 
SourceFile TrellisPlant.java - 1 + , - . java/lang/Number z { 	haven/Gob | } ~  � � � w � { java/util/ArrayList � haven/FastMesh$MeshRes MeshRes v � � � � � x � � � � � , � � � { � haven/Sprite$ResourceException ResourceException java/lang/StringBuilder No variants for grow stage  � � � � � � - � � � haven/resutil/CSprite - � y � � � � � � � � � � � � � !haven/res/lib/plants/TrellisPlant java/lang/Object haven/Sprite$Factory Factory haven/Sprite$Owner haven/Resource haven/Message java/util/Iterator java/util/Random intValue ()I a D java/lang/Math cos (D)D sin uint8 haven/FastMesh layers )(Ljava/lang/Class;)Ljava/util/Collection; java/util/Collection iterator ()Ljava/util/Iterator; hasNext ()Z next ()Ljava/lang/Object; id add (Ljava/lang/Object;)Z size haven/Sprite append -(Ljava/lang/String;)Ljava/lang/StringBuilder; (I)Ljava/lang/StringBuilder; toString ()Ljava/lang/String; %(Ljava/lang/String;Lhaven/Resource;)V 	mkrandoom ()Ljava/util/Random; '(Lhaven/Sprite$Owner;Lhaven/Resource;)V nextInt (I)I get (I)Ljava/lang/Object; mat Res Lhaven/Material$Res; � haven/Material$Res ()Lhaven/Material; m Lhaven/FastMesh; addpart � Op � Node 9(FFLhaven/render/Pipe$Op;Lhaven/render/RenderTree$Node;)V haven/Material � haven/render/Pipe$Op � haven/render/RenderTree$Node haven/render/Pipe haven/render/RenderTree plants.cjava ! ( )  *   + ,     - .  /   *     
*� *� �    0       F  G 	 H  - 1  /   "     *� �    0   
    K  L  - 2  /   *     *+2� � � �    0   
    O  P  3 7  /  �     �+� � 9� �8� 	�v8-� 
6� Y� :	,� �  :

�  � '
�  � :� 
l� 	� W���	� �  � Y� Y� � � � ,� �+�  :
� Y+,� : *� �n8!nb86*� � @	
	� � "� #� :jj� $� %� &� 'b8�����    8   J � 6 
 9 : ; < = >  *� %� (  9 : ; < = ? @  � E 0   R    S 	 T  U   V ) W L X Y Y a Z d [ m \ � ] � ^ � _ � ` � a � b � c � d � a � f  A    � 6   :  4 ] 5	  P R 	  ] _ 	 * ] t	 m � � 	 � � �	 � � �	codeentry     