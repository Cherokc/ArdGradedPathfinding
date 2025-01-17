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

import java.util.ArrayList;
import java.util.Collection;

public class RemoteUI implements UI.Receiver, UI.Runner {
    public final Session sess;
    private Session ret;

    public RemoteUI(Session sess) {
        this.sess = sess;
        Widget.initnames();
    }

    public void rcvmsg(int id, String name, Object... args) {
        PMessage msg = new PMessage(RMessage.RMSG_WDGMSG);
        msg.addint32(id);
        msg.addstring(name);
        msg.addlist(args);
        sess.queuemsg(msg);
    }

    public static class Return extends PMessage {
        public final Session ret;

        public Return(Session ret) {
            super(-1);
            this.ret = ret;
        }
    }

    public void ret(Session sess) {
        synchronized (this.sess) {
            this.ret = sess;
            this.sess.notifyAll();
        }
    }

    public Session run(UI ui) throws InterruptedException {
        try {
            ui.setreceiver(this);
            while (true) {
                PMessage msg;
                while ((msg = sess.getuimsg()) != null) {
                    try {
                        if (msg.type == RMessage.RMSG_NEWWDG) {
                            int id = msg.int32();
                            String type = msg.string();
                            int parent = msg.int32();
                            Object[] pargs = msg.list();
                            Object[] cargs = msg.list();
                            ui.newwidget(id, type, parent, pargs, cargs);
                        } else if (msg.type == RMessage.RMSG_WDGMSG) {
                            int id = msg.int32();
                            String name = msg.string();
                            ui.uimsg(id, name, msg.list());
                        } else if (msg.type == RMessage.RMSG_DSTWDG) {
                            int id = msg.int32();
                            ui.destroy(id);
                        } else if (msg.type == RMessage.RMSG_ADDWDG) {
                            int id = msg.int32();
                            int parent = msg.int32();
                            Object[] pargs = msg.list();
                            ui.addwidget(id, parent, pargs);
                        } else if (msg.type == RMessage.RMSG_WDGBAR) {
                            /* Ignore for now. */
                            Collection<Integer> deps = new ArrayList<>();
                            while (!msg.eom()) {
                                int dep = msg.int32();
                                if (dep == -1)
                                    break;
                                deps.add(dep);
                            }
                            Collection<Integer> bars = deps;
                            if (!msg.eom()) {
                                bars = new ArrayList<>();
                                while (!msg.eom()) {
                                    int bar = msg.int32();
                                    if (bar == -1)
                                        break;
                                    bars.add(bar);
                                }
                            }
                            System.out.println("RMSG_WDGBAR: " + deps + " " + bars);
                        }
                    } catch (InterruptedException e) {
                        throw e;
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
                synchronized (sess) {
                    if (ret != null) {
                        sess.close();
                        return (ret);
                    }
                    if (!sess.alive())
                        return (null);
                    sess.wait();
                }
            }
        } finally {
            sess.close();
            synchronized (sess) {
                while (sess.alive())
                    sess.wait(1000);
            }
        }
    }

    public void init(UI ui) {
        ui.sess = sess;
    }

    public String title() {
        return (sess.username);
    }
}
