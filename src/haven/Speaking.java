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

import modification.dev;

import java.awt.Color;
import java.awt.font.TextAttribute;

public class Speaking extends GAttrib implements PView.Render2D {
    public static int OY = UI.scale(Utils.getprefi("speakingoffset", 25));
    float zo;
    Text text;
    static IBox sb = null;
    Tex svans;
    static final int sx = 3;

    public Speaking(Gob gob, float zo, String text) {
        super(gob);
        if (sb == null)
            sb = new IBox("gfx/hud/emote", "tl", "tr", "bl", "br", "el", "er", "et", "eb");
        svans = Resource.loadtex("gfx/hud/emote/svans");
        this.zo = zo;
        update(text);
    }

    public void update(String text) {
        Text temp;
        try {
            temp = RichText.render(text, 200, TextAttribute.FOREGROUND, Color.BLACK);
        } catch (Exception e) {
            dev.simpleLog(e);
            temp = RichText.render(RichText.Parser.quote(text), UI.scale(200), TextAttribute.FOREGROUND, Color.BLACK);
        }
        this.text = temp;
    }

    @Override
    public void draw2d(final GOut g) {
        if (gob.sc != null)
            draw(g, gob.sc.add(new Coord(gob.sczu.mul(zo))).add(sx, -OY));
    }

    public void draw(GOut g, Coord c) {
        Coord sz = fixSize(text.tex());
        if (sz.x < 10)
            sz.x = 10;
        Coord tl = c.add(new Coord(sx, sb.cisz().y + sz.y + svans.sz().y - 1).inv());
        Coord ftl = tl.add(sb.btloff());
        g.chcolor(Color.WHITE);
        g.frect(ftl.sub(sb.btloff()), sz.add(sb.btloff().mul(2)));
//        sb.draw(g, tl, sz.add(sb.cisz()));
//        g.chcolor(Color.BLACK);
        g.chcolor();
        g.image(text.tex(), ftl, sz);
        g.chcolor(Color.WHITE);
        g.image(svans, c.add(0, -svans.sz().y));
    }

    private Coord fixSize(Tex tex) {
        Coord sz = tex.sz();
        int max = UI.scale(200);
        int p = Math.max(sz.x, sz.y);
        sz = p > max ? sz.div(1.0 * p / max) : sz;
        return (sz);
    }

    @Override
    public boolean setup(final RenderList r) {return (true);}

    @Override
    public void draw(final GOut g) {}

    @OCache.DeltaType(OCache.OD_SPEECH)
    public static class $speak implements OCache.Delta {
        @Override
        public void apply(Gob g, OCache.AttrDelta msg) {
            float zo = msg.int16() / 100.0f;
            String text = msg.string();
            if (text.isEmpty()) {
                g.delattr(Speaking.class);
            } else {
                Speaking m = g.getattr(Speaking.class);
                if (m == null) {
                    g.setattr(new Speaking(g, zo, text));
                } else {
                    m.zo = zo;
                    m.update(text);
                }
            }
        }
    }
}
