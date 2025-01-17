/*
 *  This file is part of the Haven & Hearth game client.
 *  Copyright (C) 2009 Fredrik Tolf <fredrik@dolda2000.com>, and
 *                     Björn Johannessen <johannessen.bjorn@gmail.com>
 *
 *  Redistribution and/or modification of this file is subject to the
 *  terms of the GNU Lesser General Public License, version 3, as
 *  published by the Free Software Foundation.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  Other parts of this source tree adhere to other copying
 *  rights. Please see the file `COPYING' in the root directory of the
 *  source tree for details.
 *
 *  A copy the GNU Lesser General Public License is distributed along
 *  with the source tree of which this file is a part in the file
 *  `doc/LPGL-3'. If it is missing for any reason, please see the Free
 *  Software Foundation's website at <http://www.fsf.org/>, or write
 *  to the Free Software Foundation, Inc., 59 Temple Place, Suite 330,
 *  Boston, MA 02111-1307 USA
 */

package haven;

import haven.MorphedMesh.MorphedBuf;
import haven.MorphedMesh.Morpher;
import haven.Skeleton.Pose;
import haven.render.NumberFormat;

import java.nio.FloatBuffer;
import java.nio.IntBuffer;
import java.util.Arrays;
import java.util.Collection;
import java.util.LinkedList;
import java.util.List;

/*
TODO FOR LARGE ANIMALS:
    Need to Collect:
        dragonfly
        firefly
        moon moth
        stag beetle
        silk moths
        wood grouse hens
        ladybug
    Collected:
        - jellyfish
        - waterstriders
        - monarch butterfly
        - sand fleas
        - cave moth
        - centipede
        - rats
        - grub
        - baby rabbits
        - forest snail
 */
public class PoseMorph implements Morpher.Factory {
    public final Pose pose;
    private float[][] offs;
    private int seq = -1;
    private String name = null;

    public PoseMorph(Pose pose) {
        this.pose = pose;
        offs = new float[pose.skel().blist.length][16];
    }

    public static boolean boned(FastMesh mesh) {
        BoneArray ba = mesh.vert.buf(BoneArray.class);
        if (ba == null)
            return (false);
        for (int i = 0; i < mesh.num * 3; i++) {
            if (ba.data.get(mesh.indb.get(i) * ba.n) != -1)
                return (true);
        }
        return (false);
    }

    public static String boneidp(FastMesh mesh) {
        BoneArray ba = mesh.vert.buf(BoneArray.class);
        if (ba == null)
            return (null);
        int retb = -1;
        for (int i = 0; i < mesh.num * 3; i++) {
            int vi = mesh.indb.get(i) * ba.n;
            int curb = ba.data.get(vi);
            if (curb == -1)
                return (null);
            if (retb == -1)
                retb = curb;
            else if (retb != curb)
                return (null);
            if ((ba.n != 1) && (ba.data.get(vi + 1) != -1))
                return (null);
        }
        return (ba.names[retb]);
    }

    private void update() {
        if (seq == pose.seq)
            return;
        seq = pose.seq;
        for (int i = 0; i < offs.length; i++)
            pose.boneoff(i, offs[i]);
    }

    public static class BoneArray extends VertexBuf.IntArray implements MorphedMesh.MorphArray {
        public final String[] names;

        public BoneArray(int apv, IntBuffer data, String[] names) {
            super(apv, data);
            this.names = names;
        }

        public BoneArray dup() {
            return (new BoneArray(n, Utils.bufcp(data), Utils.splice(names, 0)));
        }

        public MorphedMesh.MorphType morphtype() {
            return (MorphedMesh.MorphType.DUP);
        }
    }

    public static class WeightArray extends VertexBuf.FloatArray {
        public WeightArray(int apv, FloatBuffer data) {
            super(apv, data);
        }
    }

    @VertexBuf.ResName("bones2")
    public static class $Res implements VertexBuf.ArrayCons {
        public void cons(Collection<VertexBuf.AttribArray> dst, Resource res, Message buf, int nv) {
            int ver = buf.uint8();
            if(ver == 1) {
                NumberFormat fmt;
                String fnm = buf.string();
                switch(fnm) {
                    case "f4": fmt = NumberFormat.FLOAT32; break;
                    case "un2": fmt = NumberFormat.UNORM16; break;
                    case "un1": fmt = NumberFormat.UNORM8; break;
                    default: throw(new Resource.LoadException("Unknown bone-weight format: " + fnm, res));
                }
                read(dst, buf, nv, buf.uint8(), fmt);
            } else {
                throw(new Resource.LoadException("Unknown bone-data version: " + ver, res));
            }
        }
    }

    private static void read(Collection<VertexBuf.AttribArray> dst, Message buf, int nv, int mba, NumberFormat fmt) {
        IntBuffer ba = Utils.wibuf(nv * mba);
        for(int i = 0; i < nv * mba; i++)
            ba.put(i, -1);
        FloatBuffer bw = Utils.wfbuf(nv * mba);
        byte[] na = new byte[nv];
        List<String> bones = new LinkedList<String>();
        while(true) {
            String bone = buf.string();
            if(bone.length() == 0)
                break;
            int bidx = bones.size();
            bones.add(bone);
            while(true) {
                int run = buf.uint16();
                int vn = buf.uint16();
                if(run == 0)
                    break;
                for(int i = 0; i < run; i++, vn++) {
                    float w;
                    switch(fmt) {
                        case FLOAT32: w = buf.float32(); break;
                        case UNORM16: w = buf.unorm16(); break;
                        case UNORM8: w = buf.unorm8(); break;
                        default: throw(new AssertionError());
                    }
                    if(w == 0)
                        continue;
                    int cna = na[vn]++;
                    if(cna >= mba)
                        continue;
                    bw.put(vn * mba + cna, w);
                    ba.put(vn * mba + cna, bidx);
                }
            }
        }
        sortweights(bw, ba, mba);
        int tbn = 4;
        if(mba > tbn) {
            IntBuffer tba = Utils.wibuf(nv * tbn);
            FloatBuffer tbw = Utils.wfbuf(nv * tbn);
            for(int i = 0, off = 0, toff = 0; i < nv; i++, off += mba, toff += tbn) {
                for(int o = 0; o < tbn; o++) {
                    tbw.put(toff + o, bw.get(off + o));
                    tba.put(toff + o, ba.get(off + o));
                }
            }
            ba = tba; bw = tbw; mba = tbn;
        } else if(mba < tbn) {
            IntBuffer tba = Utils.wibuf(nv * tbn);
            FloatBuffer tbw = Utils.wfbuf(nv * tbn);
            for(int i = 0, off = 0, toff = 0; i < nv; i++, off += mba, toff += tbn) {
                for(int o = 0; o < mba; o++) {
                    tbw.put(toff + o, bw.get(off + o));
                    tba.put(toff + o, ba.get(off + o));
                }
                for(int o = mba; o < tbn; o++)
                    tba.put(toff + o, -1);
            }
            ba = tba; bw = tbw; mba = tbn;
        }
        String[] bnames = bones.toArray(new String[0]);
        normweights(bw, ba, mba);
        dst.add(new BoneArray(mba, ba, bnames));
        dst.add(new WeightArray(mba, bw));
    }

    @VertexBuf.ResName("bones")
    public static class Old$Res implements VertexBuf.ArrayCons {
        public void cons(Collection<VertexBuf.AttribArray> dst, Resource res, Message buf, int nv) {
            read(dst, buf, nv, buf.uint8(), NumberFormat.FLOAT32);
        }
    }

    public static void sortweights(FloatBuffer bw, IntBuffer ba, int mba) {
        Integer[] p = new Integer[mba];
        float[] cw = new float[mba];
        int[] ca = new int[mba];
        for(int i = 0; i < bw.capacity(); i += mba) {
            int n = 0;
            for(int o = 0; o < mba; o++) {
                if(ba.get(i + o) < 0)
                    break;
                p[n++] = Integer.valueOf(o);
            }
            int ci = i;
            Arrays.sort(p, 0, n, (a, b) -> {
                float wa = bw.get(ci + a), wb = bw.get(ci + b);
                if(wa < wb)
                    return(1);
                else if(wa > wb)
                    return(-1);
                return(0);
            });
            for(int o = 0; o < n; o++) {
                cw[o] = bw.get(i + o);
                ca[o] = ba.get(i + o);
            }
            for(int o = 0; o < n; o++) {
                bw.put(i + o, cw[p[o]]);
                ba.put(i + o, ca[p[o]]);
            }
        }
    }

    public static void normweights(FloatBuffer bw, IntBuffer ba, int mba) {
        int i = 0;
        while (i < bw.capacity()) {
            float tw = 0.0f;
            int n = 0;
            for (int o = 0; o < mba; o++) {
                if (ba.get(i + o) < 0)
                    break;
                tw += bw.get(i + o);
                n++;
            }
            if (tw != 1.0f) {
                for (int o = 0; o < n; o++)
                    bw.put(i + o, bw.get(i + o) / tw);
            }
            i += mba;
        }
    }

    public Morpher create(final MorphedBuf vb) {
        BoneArray ob = vb.from.buf(BoneArray.class);
        BoneArray nb = vb.buf(BoneArray.class);
        int[] xl = new int[nb.names.length];
        for (int i = 0; i < xl.length; i++) {
            Skeleton.Bone b = pose.skel().bones.get(nb.names[i]);
            if (b == null)
                throw (new RuntimeException("Bone \"" + nb.names[i] + "\" in vertex-buf reference does not exist in skeleton " + pose.skel()));
            xl[i] = b.idx;
        }
        for (int i = 0; i < ob.data.capacity(); i++) {
            if (ob.data.get(i) == -1)
                nb.data.put(i, -1);
            else
                nb.data.put(i, xl[ob.data.get(i)]);
        }
        return (new Morpher() {
            private int pseq = -1;

            public boolean update() {
                if (pseq == pose.seq)
                    return (false);
                PoseMorph.this.update();
                pseq = pose.seq;
                return (true);
            }

            public void morphp(FloatBuffer dst, FloatBuffer src) {
                BoneArray ba = vb.buf(BoneArray.class);
                int apv = ba.n;
                IntBuffer bl = ba.data;
                FloatBuffer wl = vb.buf(WeightArray.class).data;
                int vo = 0, ao = 0;
                for (int i = 0; i < vb.num; i++) {
                    float opx = src.get(vo), opy = src.get(vo + 1), opz = src.get(vo + 2);
                    float npx = 0, npy = 0, npz = 0;
                    float rw = 1;
                    for (int o = 0; o < apv; o++) {
                        int bi = bl.get(ao + o);
                        if (bi < 0)
                            break;
                        float bw = wl.get(ao + o);
                        float[] xf = offs[bi];
                        //Big Animals HERE!!!!  ! ! ! !
                        if (!Config.biganimals) {
                            if (name == null) {
                                name = ba.names[0];
                                //System.out.println(name);
                            }
                            //Squirrel > centipede > forest lizard > grasshopper > rabbit > toad
                            //Large Animal
                            npx += ((xf[0] * opx) + (xf[4] * opy) + (xf[8] * opz) + xf[12]) * bw;
                            npy += ((xf[1] * opx) + (xf[5] * opy) + (xf[9] * opz) + xf[13]) * bw;
                            npz += ((xf[2] * opx) + (xf[6] * opy) + (xf[10] * opz) + xf[14]) * bw;
                        } else {
                            if (name == null) {
                                name = ba.names[0];
                                //System.out.println(name);
                            }
                            if (Config.smallworld) {
                                npx += ((xf[0] * opx) + (xf[4] * opy) + (xf[8] * opz) + xf[12]) * bw * 6;
                                npy += ((xf[1] * opx) + (xf[5] * opy) + (xf[9] * opz) + xf[13]) * bw * 6;
                                npz += ((xf[2] * opx) + (xf[6] * opy) + (xf[10] * opz) + xf[14]) * bw * 6;
                            } else {
                                if (Config.bigAnimals.contains(name)) {
                                    npx += ((xf[0] * opx) + (xf[4] * opy) + (xf[8] * opz) + xf[12]) * bw * 2;
                                    npy += ((xf[1] * opx) + (xf[5] * opy) + (xf[9] * opz) + xf[13]) * bw * 2;
                                    npz += ((xf[2] * opx) + (xf[6] * opy) + (xf[10] * opz) + xf[14]) * bw * 2;
                                } else {
                                    npx += ((xf[0] * opx) + (xf[4] * opy) + (xf[8] * opz) + xf[12]) * bw;
                                    npy += ((xf[1] * opx) + (xf[5] * opy) + (xf[9] * opz) + xf[13]) * bw;
                                    npz += ((xf[2] * opx) + (xf[6] * opy) + (xf[10] * opz) + xf[14]) * bw;
                                }
                            }
                        }
                        rw -= bw;
                    }
                    npx += opx * rw;
                    npy += opy * rw;
                    npz += opz * rw;
                    dst.put(vo, npx);
                    dst.put(vo + 1, npy);
                    dst.put(vo + 2, npz);
                    vo += 3;
                    ao += apv;
                }
            }

            public void morphd(FloatBuffer dst, FloatBuffer src) {
                BoneArray ba = vb.buf(BoneArray.class);
                int apv = ba.n;
                IntBuffer bl = ba.data;
                FloatBuffer wl = vb.buf(WeightArray.class).data;
                int vo = 0, ao = 0;
                for (int i = 0; i < vb.num; i++) {
                    float onx = src.get(vo), ony = src.get(vo + 1), onz = src.get(vo + 2);
                    float nnx = 0, nny = 0, nnz = 0;
                    float rw = 1;
                    for (int o = 0; o < apv; o++) {
                        int bi = bl.get(ao + o);
                        if (bi < 0)
                            break;
                        float bw = wl.get(ao + o);
                        float[] xf = offs[bi];
                        nnx += ((xf[0] * onx) + (xf[4] * ony) + (xf[8] * onz)) * bw;
                        nny += ((xf[1] * onx) + (xf[5] * ony) + (xf[9] * onz)) * bw;
                        nnz += ((xf[2] * onx) + (xf[6] * ony) + (xf[10] * onz)) * bw;
                        rw -= bw;
                    }
                    nnx += onx * rw;
                    nny += ony * rw;
                    nnz += onz * rw;
                    dst.put(vo, nnx);
                    dst.put(vo + 1, nny);
                    dst.put(vo + 2, nnz);
                    vo += 3;
                    ao += apv;
                }
            }
        });
    }
}
