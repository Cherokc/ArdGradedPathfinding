Haven Resource 1 src �  Svaj.java /* Preprocessed source code */
package haven.res.lib.svaj;

import haven.*;
import haven.render.*;
import haven.render.sl.*;
import static haven.render.sl.Cons.*;
import static haven.render.sl.Type.*;
import static haven.render.sl.Function.PDir.*;

public class Svaj extends State implements InstanceBatch.AttribState {
    private static final float[] nildat = {0, 0, 0, 0};
    public static final Slot<Svaj> slot = new Slot<Svaj>(Slot.Type.GEOM, Svaj.class)
	.instanced(new Instancable<Svaj>() {
		public Instancer<Svaj> instid(Svaj st) {return(instancer);}
	    });
    public static final InstancedUniform u_zharmonic = new InstancedUniform.Vec4("zharm", p -> {
	    Svaj st = p.get(slot);
	    return((st == null) ? nildat : st.zharmonic);
	}, slot);
    public static final InstancedUniform u_charmonic = new InstancedUniform.Vec4("charm", p -> {
	    Svaj st = p.get(slot);
	    return((st == null) ? nildat : st.charmonic);
	}, slot);
    public static final InstancedUniform u_origin = new InstancedUniform.Vec4("s_orig", p -> {
	    Svaj st = p.get(slot);
	    Coord3f o = (st == null) ? Coord3f.o : st.origin;
	    return(new float[] {o.x, o.y, o.z, 0});
	}, slot);
    public final float[] zharmonic, charmonic;
    public final Coord3f origin;

    public Svaj(Coord3f zhvec, float zhfreq, Coord3f chvec, float chfreq, Coord3f origin) {
	this.zharmonic = new float[] {zhvec.x, zhvec.y, zhvec.z, zhfreq * (float)Math.PI * 2};
	this.charmonic = new float[] {chvec.x, chvec.y, chvec.z, chfreq * (float)Math.PI * 2};
	this.origin = origin;
    }

    public void apply(Pipe buf) {
	buf.put(slot, this);
    }

    public static final Function svaja = new Function.Def(VEC4, "svaja") {{
	Expression in = param(IN, VEC4).ref();
	Expression off = code.local(VEC3, sub(pick(in, "xyz"), pick(u_origin.ref(), "xyz"))).ref();
	code.add(new Return(add(in,
				vec4(mul(pick(u_zharmonic.ref(), "xyz"),
					 sin(mul(FrameInfo.u_time.ref(), pick(u_zharmonic.ref(), "w"))),
					 max(pick(off, "z"),
					     l(0.0))),
				     l(0.0)),
				vec4(mul(pick(u_charmonic.ref(), "xyz"),
					 sin(mul(FrameInfo.u_time.ref(), pick(u_charmonic.ref(), "w"))),
					 max(sub(length(pick(off, "xy")), l(5.0)),
					     l(0.0))),
				     l(0.0)))));
    }};

    public static final ShaderMacro sh =  prog -> {
	Homo3D homo = Homo3D.get(prog);
	homo.mapv.mod(svaja::call, 0);
    };
    public ShaderMacro shader() {
	return(sh);
    }

    private static final Instancer<Svaj> instancer = new Instancer<Svaj>() {
	    final Svaj instanced = new Svaj(Coord3f.o, 0, Coord3f.o, 0, null) {
		    private final ShaderMacro shader = ShaderMacro.compose(Instancer.mkinstanced, sh);
		    public ShaderMacro shader() {return(shader);}
		};

	    public Svaj inststate(Svaj uinst, InstanceBatch bat) {
		return(instanced);
	    }
	};

    public InstancedAttribute[] attribs() {
	return(new InstancedAttribute[] {u_zharmonic.attrib, u_charmonic.attrib, u_origin.attrib});
    }
}

/* >spr: SvajOl */
src   SvajOl.java /* Preprocessed source code */
package haven.res.lib.svaj;

import haven.*;
import haven.render.*;
import haven.render.sl.*;
import static haven.render.sl.Cons.*;
import static haven.render.sl.Type.*;
import static haven.render.sl.Function.PDir.*;

public class SvajOl extends Sprite implements Gob.SetupMod {
    public static final float v1 = 0.5f, v2 = 0.5f;
    public final Coord3f zhvec, chvec;
    public final float zhfreq, chfreq;

    private static float r(float a, float b) {
	return(a + ((float)Math.random() * (b - a)));
    }

    public SvajOl(Owner owner) {
	super(owner, Resource.classres(SvajOl.class));
	this.zhvec = new Coord3f(r(-0.05f * v1, 0.05f * v1), r(-0.05f * v1, 0.05f * v1), r(-0.01f * v1, 0.01f * v1));
	this.zhfreq = r(0.05f, 0.2f);
	this.chvec = new Coord3f(r(-0.03f * v2, 0.03f * v2), r(-0.03f * v2, 0.03f * v2), r(-0.03f * v2, 0.03f * v2));
	this.chfreq = r(0.5f, 1.5f);
    }

    public static SvajOl mksprite(Owner owner, Resource res, Message sdt) {
	return(new SvajOl(owner));
    }

    private Svaj cur = null;
    private State st() {
	if(!(owner instanceof Gob))
	    return(null);
	Gob gob = (Gob)owner;
	Coord3f origin;
	try {
	    origin = gob.getc();
	} catch(Loading l) {
	    return(cur);
	}
	if((cur == null) || !Utils.eq(origin, cur.origin)) {
	    origin.y = -origin.y;
	    cur = new Svaj(zhvec, zhfreq, chvec, chfreq, origin);
	}
	return(cur);
    }

    public Pipe.Op placestate() {
	return(st());
    }

    public boolean tick(double dt) {
	return(false);
    }
}

/* >objdelta: GobSvaj */
src   GobSvaj.java /* Preprocessed source code */
package haven.res.lib.svaj;

import haven.*;
import haven.render.*;
import haven.render.sl.*;
import static haven.render.sl.Cons.*;
import static haven.render.sl.Type.*;
import static haven.render.sl.Function.PDir.*;

public class GobSvaj extends GAttrib implements Gob.SetupMod {
    public static final float v1 = 0.5f, v2 = 0.25f;
    public final Coord3f zhvec, chvec;
    public final float zhfreq, chfreq;

    private static float r(float a, float b) {
	return(a + ((float)Math.random() * (b - a)));
    }

    public GobSvaj(Gob gob, float v1, float v2) {
	super(gob);
	this.zhvec = new Coord3f(r(-0.05f * v1, 0.05f * v1), r(-0.05f * v1, 0.05f * v1), r(-0.01f * v1, 0.01f * v1));
	this.zhfreq = r(0.05f, 0.2f);
	this.chvec = new Coord3f(r(-0.02f * v2, 0.02f * v2), r(-0.02f * v2, 0.02f * v2), r(-0.03f * v2, 0.03f * v2));
	this.chfreq = r(0.5f, 1.5f);
    }

    public GobSvaj(Gob gob) {
	this(gob, v1, v2);
    }

    public static void parse(Gob gob, Message sdt) {
	float V1 = v1, V2 = v2;
	if(!sdt.eom()) {
	    int fl = sdt.uint8();
	    V1 = sdt.float8();
	    V2 = sdt.float8();
	}
	gob.setattr(new GobSvaj(gob, V1, V2));
    }

    private Svaj cur = null;
    private State st() {
	Coord3f origin;
	try {
	    origin = gob.getc();
	} catch(Loading l) {
	    return(cur);
	}
	if((cur == null) || !Utils.eq(origin, cur.origin)) {
	    origin.y = -origin.y;
	    cur = new Svaj(zhvec, zhfreq, chvec, chfreq, origin);
	}
	return(cur);
    }

    public Pipe.Op placestate() {
	return(st());
    }
}
code �  haven.res.lib.svaj.Svaj$1 ����   4 &
  
   
       <init> ()V Code LineNumberTable instid ! 	Instancer InnerClasses 9(Lhaven/res/lib/svaj/Svaj;)Lhaven/render/State$Instancer; 	Signature T(Lhaven/res/lib/svaj/Svaj;)Lhaven/render/State$Instancer<Lhaven/res/lib/svaj/Svaj;>; 4(Lhaven/render/State;)Lhaven/render/State$Instancer; Instancable MLjava/lang/Object;Lhaven/render/State$Instancable<Lhaven/res/lib/svaj/Svaj;>; 
SourceFile 	Svaj.java EnclosingMethod  	 " # haven/res/lib/svaj/Svaj   haven/res/lib/svaj/Svaj$1 java/lang/Object $ haven/render/State$Instancable haven/render/State$Instancer 
access$000  ()Lhaven/render/State$Instancer; haven/render/State 
svaj.cjava 0           	  
        *� �                
        � �                A    
   !     	*+� � �                 %             	   	             code c  haven.res.lib.svaj.Svaj ����   4 �	  k
 4 l	 m n	 m o	 m p q@I�	  r	  s	  t	  u v w	  x y	  z	 { |	  }	  ~
  �	  �	  �
 � �   �
 � � �
 � � v � �	 m �	  � �	 � �
  � �
 " l
  � � �  �
 % � �  � �  � �	 � � F
 - �  � �
 2 l � � InnerClasses nildat [F slot Slot Lhaven/render/State$Slot; 	Signature 4Lhaven/render/State$Slot<Lhaven/res/lib/svaj/Svaj;>; u_zharmonic "Lhaven/render/sl/InstancedUniform; u_charmonic u_origin 	zharmonic 	charmonic origin Lhaven/Coord3f; svaja Lhaven/render/sl/Function; sh Lhaven/render/sl/ShaderMacro; 	instancer � 	Instancer Lhaven/render/State$Instancer; 9Lhaven/render/State$Instancer<Lhaven/res/lib/svaj/Svaj;>; <init> 2(Lhaven/Coord3f;FLhaven/Coord3f;FLhaven/Coord3f;)V Code LineNumberTable apply (Lhaven/render/Pipe;)V shader ()Lhaven/render/sl/ShaderMacro; attribs '()[Lhaven/render/sl/InstancedAttribute; lambda$static$4 #(Lhaven/render/sl/ProgramContext;)V lambda$null$3 T(Lhaven/render/sl/Function;Lhaven/render/sl/Expression;)Lhaven/render/sl/Expression; lambda$static$2 (Lhaven/render/Pipe;)[F StackMapTable � � lambda$static$1 8 lambda$static$0 
access$000  ()Lhaven/render/State$Instancer; <clinit> ()V 
SourceFile 	Svaj.java J M O h � � � � � � � java/lang/Math B 8 C 8 D E 9 ; � � � H I "haven/render/sl/InstancedAttribute > ? � � � @ ? A ? � � � � � F G � � � BootstrapMethods � � � � S � � � � haven/render/sl/Expression � � � � � haven/res/lib/svaj/Svaj � E 7 8 haven/render/State$Slot � � � O � haven/res/lib/svaj/Svaj$1 � � %haven/render/sl/InstancedUniform$Vec4 Vec4 zharm � ^ S � O � charm � s_orig � haven/res/lib/svaj/Svaj$2 � � � O � Z � � V haven/res/lib/svaj/Svaj$3 haven/render/State � &haven/render/InstanceBatch$AttribState AttribState haven/render/State$Instancer haven/Coord3f x F y z haven/render/Pipe put 0(Lhaven/render/State$Slot;Lhaven/render/State;)V  haven/render/sl/InstancedUniform attrib $Lhaven/render/sl/InstancedAttribute; haven/render/Homo3D get 7(Lhaven/render/sl/ProgramContext;)Lhaven/render/Homo3D; mapv Value  Lhaven/render/sl/ValBlock$Value; java/lang/Object getClass ()Ljava/lang/Class;
 � � &(Ljava/lang/Object;)Ljava/lang/Object;
  � :(Lhaven/render/sl/Expression;)Lhaven/render/sl/Expression; >(Lhaven/render/sl/Function;)Ljava/util/function/UnaryOperator; � haven/render/sl/ValBlock$Value mod &(Ljava/util/function/UnaryOperator;I)V haven/render/sl/Function call ;([Lhaven/render/sl/Expression;)Lhaven/render/sl/Expression; /(Lhaven/render/State$Slot;)Lhaven/render/State; o haven/render/State$Slot$Type Type GEOM Lhaven/render/State$Slot$Type; 2(Lhaven/render/State$Slot$Type;Ljava/lang/Class;)V 	instanced � Instancable ;(Lhaven/render/State$Instancable;)Lhaven/render/State$Slot;
  � ()Ljava/util/function/Function; L(Ljava/lang/String;Ljava/util/function/Function;[Lhaven/render/State$Slot;)V
  �
  � haven/render/sl/Type VEC4 Lhaven/render/sl/Type; +(Lhaven/render/sl/Type;Ljava/lang/String;)V
  � modify haven/render/InstanceBatch � � � [ \ haven/render/sl/ValBlock haven/render/State$Instancable d ^ b ^ ] ^ Y Z "java/lang/invoke/LambdaMetafactory metafactory � Lookup �(Ljava/lang/invoke/MethodHandles$Lookup;Ljava/lang/String;Ljava/lang/invoke/MethodType;Ljava/lang/invoke/MethodType;Ljava/lang/invoke/MethodHandle;Ljava/lang/invoke/MethodType;)Ljava/lang/invoke/CallSite; � %java/lang/invoke/MethodHandles$Lookup java/lang/invoke/MethodHandles 
svaj.cjava !  4  5   7 8    9 ;  <    =  > ?    @ ?    A ?    B 8    C 8    D E    F G    H I    J M  <    N   O P  Q   ~     V*� *�Y+� QY+� QY+� QY$jjQ� *�Y-� QY-� QY-� QYjjQ� 	*� 
�    R          ! ) " O # U $  S T  Q   '     +� *�  �    R   
    ' 
 (  U V  Q        � �    R       ?  W X  Q   8      � Y� � SY� � SY� � S�    R       N
 Y Z  Q   ;     *� L+� � Y� W�   � �    R       ;  <  =
 [ \  Q   %     *� Y+S� �    R       <
 ] ^  Q   k     9*� �  � L+� 	� � +� 
M�Y,� QY,� QY,� QYQ�    _    �  `C a R           
 b ^  Q   J     *� �  � L+� 	� � +� 	�    _    �  `C c R   
      
 d ^  Q   J     *� �  � L+� 	� � +� �    _    �  `C c R   
       e f  Q         � �    R       
  g h  Q   �      ��YQYQYQYQ� � Y�  � !� "Y� #� $� � %Y&� '  � Y� S� (� � %Y)� *  � Y� S� (� � %Y+� ,  � Y� S� (� � -Y� ./� 0� � 1  � � 2Y� 3� �    R   & 	      )  /  J  e  � * � : � B  �   4  �  � � � �  � � � �  � � � �  � � � �  � � � i    � 6   Z  2      -      "       4 : 	 K 4 L	 % { � 	 5 � �	 � � � �  �@ � 4 �	 � � � code �  haven.res.lib.svaj.GobSvaj ����   4 �
 H I
 & J	  K L�L��=L��
  M�#�
<#�

  N	  O>L��	  P���
<��
��<�	  Q?   ?�  	  R S>�  
  T
 U V
 U W
 U X
 Y Z	  [
 Y \ ]	 # ^
 _ `	  a b
 # c
  d e f v1 F ConstantValue v2 zhvec Lhaven/Coord3f; chvec zhfreq chfreq cur Lhaven/res/lib/svaj/Svaj; r (FF)F Code LineNumberTable <init> (Lhaven/Gob;FF)V (Lhaven/Gob;)V parse (Lhaven/Gob;Lhaven/Message;)V StackMapTable st ()Lhaven/render/State; ] L 
placestate i Op InnerClasses ()Lhaven/render/Pipe$Op; 
SourceFile GobSvaj.java j k l 7 9 1 2 haven/Coord3f 3 4 7 m , - / ) . - 0 ) haven/res/lib/svaj/GobSvaj 7 8 n o p q r s t u v w x y z { haven/Loading | - } ~  � ) haven/res/lib/svaj/Svaj 7 � = > haven/GAttrib haven/Gob$SetupMod SetupMod � haven/render/Pipe$Op java/lang/Math random ()D (FFF)V haven/Message eom ()Z uint8 ()I float8 ()F 	haven/Gob setattr (Lhaven/GAttrib;)V gob Lhaven/Gob; getc ()Lhaven/Coord3f; origin haven/Utils eq '(Ljava/lang/Object;Ljava/lang/Object;)Z y 2(Lhaven/Coord3f;FLhaven/Coord3f;FLhaven/Coord3f;)V haven/render/Pipe 
svaj.cjava !  &  '   ( )  *      + )  *      , -    . -    / )    0 )    1 2    
 3 4  5   #     "� �#"fjb�    6       �  7 8  5   �     y*+� *� *� Y$j$j� $j$j� $j	$j� � 
� *� � *� Y%j%j� %j%j� %j%j� � 
� *� � �    6       �  � 
 � 6 � A � m � x �  7 9  5   &     
*+� �    6   
    � 	 � 	 : ;  5   i     ,EF+� � +� 6+� E+� F*� Y*$%� � �    <    �  6       �  �  �  �  �  � + �  = >  5   �     P*� � L� 	M*� �*� � +*� �  � !� (++� "v� "*� #Y*� *� *� *� +� $� *� �        <    K ?�  @$ 6   "    �  �  �  �  � & � / � K �  A E  5        *� %�    6       �  F    � D     B h C	 ' Y g	code E  haven.res.lib.svaj.Svaj$2 ����   4 �
 $ -	 . /	 0 1
 # 2
 3 4	 # 5	 0 6 7
 8 9	 , :
 ; <
 8 =
 > ?
 @ 4 A B	 , C	 D E
 F G H
 8 I
 8 J K
 8 L
 8 M
 8 N	 , O P
 8 Q@      
 8 R
  S
 > T U X <init> +(Lhaven/render/sl/Type;Ljava/lang/String;)V Code LineNumberTable 
SourceFile 	Svaj.java EnclosingMethod Z % & [ ] ^ _ ` a b d e f i j k l a xyz m n o p q r f s t w x y { | haven/render/sl/Return haven/render/sl/Expression } q ~  � � f � w � � � � z � � � � � � � q xy � � � � % � � � haven/res/lib/svaj/Svaj$2 InnerClasses � haven/render/sl/Function$Def Def haven/res/lib/svaj/Svaj haven/render/sl/Function$PDir PDir IN Lhaven/render/sl/Function$PDir; haven/render/sl/Type VEC4 Lhaven/render/sl/Type; param 	Parameter [(Lhaven/render/sl/Function$PDir;Lhaven/render/sl/Type;)Lhaven/render/sl/Function$Parameter; "haven/render/sl/Function$Parameter ref � Ref  ()Lhaven/render/sl/Variable$Ref; code Lhaven/render/sl/Block; VEC3 haven/render/sl/Cons pick F(Lhaven/render/sl/Expression;Ljava/lang/String;)Lhaven/render/sl/Pick; u_origin "Lhaven/render/sl/InstancedUniform;  haven/render/sl/InstancedUniform ()Lhaven/render/sl/Expression; sub � Sub U(Lhaven/render/sl/Expression;Lhaven/render/sl/Expression;)Lhaven/render/sl/BinOp$Sub; haven/render/sl/Block local Local Q(Lhaven/render/sl/Type;Lhaven/render/sl/Expression;)Lhaven/render/sl/Block$Local; haven/render/sl/Block$Local u_zharmonic haven/render/FrameInfo u_time Lhaven/render/sl/Uniform; haven/render/sl/Uniform � Global � '()Lhaven/render/sl/Variable$Global$Ref; mul 4([Lhaven/render/sl/Expression;)Lhaven/render/sl/Mul; sin :(Lhaven/render/sl/Expression;)Lhaven/render/sl/Expression; l !(D)Lhaven/render/sl/FloatLiteral; max ;([Lhaven/render/sl/Expression;)Lhaven/render/sl/Expression; vec4 9([Lhaven/render/sl/Expression;)Lhaven/render/sl/Vec4Cons; u_charmonic length add 4([Lhaven/render/sl/Expression;)Lhaven/render/sl/Add; (Lhaven/render/sl/Expression;)V (Lhaven/render/sl/Statement;)V haven/render/sl/Function � haven/render/sl/Variable$Ref � haven/render/sl/BinOp$Sub haven/render/sl/Variable$Global #haven/render/sl/Variable$Global$Ref haven/render/sl/Variable haven/render/sl/BinOp 
svaj.cjava 0 # $        % &  '  �    -*+,� *� � � � N*� � -� 	� 
� � 	� � � :*� � Y� Y-SY� Y� Y� � � 	SY� Y� � SY� � � 	S� � SY� Y� 	SY� S� S� SY� S� SY� Y� Y� � � 	SY� Y� � SY� � � 	S� � SY� Y� 	�  � � SY� S� S� SY� S� S�  � !� "�    (   Z    *  +  , 7 - X . l / � 0 � 1 � 0 � . � 2 � . � 3 � 4 � 5 6 5 3 7 3# -, 8  )    � V   J 	 #      $ W Y 	 . W \@ 3 W c 	 g � h  u � v 	 @ > z  � � � 	 � � h  +    ,  code   haven.res.lib.svaj.Svaj$3 ����   4 -
 	  	  
  	    !
  " # $ & InnerClasses 	instanced Lhaven/res/lib/svaj/Svaj; <init> ()V Code LineNumberTable 	inststate P(Lhaven/res/lib/svaj/Svaj;Lhaven/render/InstanceBatch;)Lhaven/res/lib/svaj/Svaj; F(Lhaven/render/State;Lhaven/render/InstanceBatch;)Lhaven/render/State; 	Signature 	Instancer KLjava/lang/Object;Lhaven/render/State$Instancer<Lhaven/res/lib/svaj/Svaj;>; 
SourceFile 	Svaj.java EnclosingMethod   haven/res/lib/svaj/Svaj$3$1 ' ( )  *   haven/res/lib/svaj/Svaj   haven/res/lib/svaj/Svaj$3 java/lang/Object + haven/render/State$Instancer haven/Coord3f o Lhaven/Coord3f; M(Lhaven/res/lib/svaj/Svaj$3;Lhaven/Coord3f;FLhaven/Coord3f;FLhaven/Coord3f;)V haven/render/State 
svaj.cjava 0  	  
                6 	    *� *� Y*� � � � �       
    B  C             *� �           IA       "     
*+� ,� �           B      ,                        
 % 	       code �  haven.res.lib.svaj.Svaj$3$1 ����   4 -	  
 	  	  	    	     ! shader Lhaven/render/sl/ShaderMacro; this$0 " InnerClasses Lhaven/res/lib/svaj/Svaj$3; <init> M(Lhaven/res/lib/svaj/Svaj$3;Lhaven/Coord3f;FLhaven/Coord3f;FLhaven/Coord3f;)V Code LineNumberTable ()Lhaven/render/sl/ShaderMacro; 
SourceFile 	Svaj.java EnclosingMethod    # haven/render/sl/ShaderMacro % '  (  ) * 
  haven/res/lib/svaj/Svaj$3$1 haven/res/lib/svaj/Svaj haven/res/lib/svaj/Svaj$3 2(Lhaven/Coord3f;FLhaven/Coord3f;FLhaven/Coord3f;)V + haven/render/State$Instancer 	Instancer mkinstanced sh compose =([Lhaven/render/sl/ShaderMacro;)Lhaven/render/sl/ShaderMacro; haven/render/State 
svaj.cjava    	     
                 E     )*+� *,%� *� Y� SY� S� � �       
    C  D  
           *� �           E      ,                    $ &	       code �  haven.res.lib.svaj.SvajOl ����   4 }
 I J K
 L M
 " N	  O P����<���
  Q���
;��

  R	  S=L��>L��	  T�u<u	  U?   ?�  	  V
  W	  X Y
  Z [	  \
 ] ^	  _ `
  a
  b c d v1 F ConstantValue v2 zhvec Lhaven/Coord3f; chvec zhfreq chfreq cur Lhaven/res/lib/svaj/Svaj; r (FF)F Code LineNumberTable <init> f Owner InnerClasses (Lhaven/Sprite$Owner;)V mksprite P(Lhaven/Sprite$Owner;Lhaven/Resource;Lhaven/Message;)Lhaven/res/lib/svaj/SvajOl; st ()Lhaven/render/State; StackMapTable K Y [ P 
placestate h Op ()Lhaven/render/Pipe$Op; tick (D)Z 
SourceFile SvajOl.java i j k haven/res/lib/svaj/SvajOl l m n 3 o - . haven/Coord3f / 0 3 p ( ) + % * ) , % 3 7 q r 	haven/Gob s t haven/Loading u ) v w x y % haven/res/lib/svaj/Svaj 3 z : ; haven/Sprite haven/Gob$SetupMod SetupMod haven/Sprite$Owner { haven/render/Pipe$Op java/lang/Math random ()D haven/Resource classres #(Ljava/lang/Class;)Lhaven/Resource; '(Lhaven/Sprite$Owner;Lhaven/Resource;)V (FFF)V owner Lhaven/Sprite$Owner; getc ()Lhaven/Coord3f; origin haven/Utils eq '(Ljava/lang/Object;Ljava/lang/Object;)Z y 2(Lhaven/Coord3f;FLhaven/Coord3f;FLhaven/Coord3f;)V haven/render/Pipe 
svaj.cjava !  "  #   $ %  &      ' %  &      ( )    * )    + %    , %    - .    
 / 0  1   #     "� �#"fjb�    2       Y  3 7  1   �     f*+� � *� *� Y� 	� 	
� 	� � *� 	� *� Y� 	� 	� 	� � *� 	� �    2       ] 
 h  ^ / _ : ` Z a e b 	 8 9  1   !     	� Y*� �    2       e  : ;  1   �     a*� � � �*� � L+� M� 	N*� �*� � ,*� � � � (,,� v� *� Y*� *� *� *� ,�  � *� �       <    �   = >  ?�  @$ 2   .    j 
 k  l  o  r  p  q " s 7 t @ u \ w  A D  1        *� !�    2       {  E F  1        �    2         G    | 6     4 " 5	 B g C	 #  e	codeentry E   spr haven.res.lib.svaj.SvajOl objdelta haven.res.lib.svaj.GobSvaj   