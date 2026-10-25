local Engine = {}

local MATE = 100000
local INF = math.huge
local VAL = {P = 100, N = 320, B = 330, R = 500, Q = 900, K = 0}
local PIDX = {P = 1, N = 2, B = 3, R = 4, Q = 5, K = 6}
local PHASE = {P = 0, N = 1, B = 1, R = 2, Q = 4, K = 0}
local PROMO = {"Q", "R", "B", "N"}
local PASS = {0, 5, 10, 20, 35, 60, 100, 0}

local PST = {
    P = {
        {0, 0, 0, 0, 0, 0, 0, 0},
        {5, 10, 10, -20, -20, 10, 10, 5},
        {5, -5, -10, 0, 0, -10, -5, 5},
        {0, 0, 0, 20, 20, 0, 0, 0},
        {5, 5, 10, 25, 25, 10, 5, 5},
        {10, 10, 20, 30, 30, 20, 10, 10},
        {50, 50, 50, 50, 50, 50, 50, 50},
        {0, 0, 0, 0, 0, 0, 0, 0},
    },
    N = {
        {-50, -40, -30, -30, -30, -30, -40, -50},
        {-40, -20, 0, 5, 5, 0, -20, -40},
        {-30, 5, 10, 15, 15, 10, 5, -30},
        {-30, 0, 15, 20, 20, 15, 0, -30},
        {-30, 5, 15, 20, 20, 15, 5, -30},
        {-30, 0, 10, 15, 15, 10, 0, -30},
        {-40, -20, 0, 0, 0, 0, -20, -40},
        {-50, -40, -30, -30, -30, -30, -40, -50},
    },
    B = {
        {-20, -10, -10, -10, -10, -10, -10, -20},
        {-10, 5, 0, 0, 0, 0, 5, -10},
        {-10, 10, 10, 10, 10, 10, 10, -10},
        {-10, 0, 10, 10, 10, 10, 0, -10},
        {-10, 5, 5, 10, 10, 5, 5, -10},
        {-10, 0, 5, 10, 10, 5, 0, -10},
        {-10, 0, 0, 0, 0, 0, 0, -10},
        {-20, -10, -10, -10, -10, -10, -10, -20},
    },
    R = {
        {0, 0, 0, 5, 5, 0, 0, 0},
        {-5, 0, 0, 0, 0, 0, 0, -5},
        {-5, 0, 0, 0, 0, 0, 0, -5},
        {-5, 0, 0, 0, 0, 0, 0, -5},
        {-5, 0, 0, 0, 0, 0, 0, -5},
        {-5, 0, 0, 0, 0, 0, 0, -5},
        {5, 10, 10, 10, 10, 10, 10, 5},
        {0, 0, 0, 0, 0, 0, 0, 0},
    },
    Q = {
        {-20, -10, -10, -5, -5, -10, -10, -20},
        {-10, 0, 5, 0, 0, 0, 0, -10},
        {-10, 5, 5, 5, 5, 5, 0, -10},
        {0, 0, 5, 5, 5, 5, 0, -5},
        {-5, 0, 5, 5, 5, 5, 0, -5},
        {-10, 0, 5, 5, 5, 5, 0, -10},
        {-10, 0, 0, 0, 0, 0, 0, -10},
        {-20, -10, -10, -5, -5, -10, -10, -20},
    },
    K = {
        {20, 30, 10, 0, 0, 10, 30, 20},
        {20, 20, 0, 0, 0, 0, 20, 20},
        {-10, -20, -20, -20, -20, -20, -20, -10},
        {-20, -30, -30, -40, -40, -30, -30, -20},
        {-30, -40, -40, -50, -50, -40, -40, -30},
        {-30, -40, -40, -50, -50, -40, -40, -30},
        {-30, -40, -40, -50, -50, -40, -40, -30},
        {-30, -40, -40, -50, -50, -40, -40, -30},
    },
}

local KEG = {
    {-50, -30, -30, -30, -30, -30, -30, -50},
    {-30, -30, 0, 0, 0, 0, -30, -30},
    {-30, -10, 20, 30, 30, 20, -10, -30},
    {-30, -10, 30, 40, 40, 30, -10, -30},
    {-30, -10, 30, 40, 40, 30, -10, -30},
    {-30, -10, 20, 30, 30, 20, -10, -30},
    {-30, -20, -10, 0, 0, -10, -20, -30},
    {-50, -40, -30, -20, -20, -30, -40, -50},
}

local KN = {{2, 1}, {2, -1}, {-2, 1}, {-2, -1}, {1, 2}, {1, -2}, {-1, 2}, {-1, -2}}
local KG = {{1, 0}, {-1, 0}, {0, 1}, {0, -1}, {1, 1}, {1, -1}, {-1, 1}, {-1, -1}}
local DG = {{1, 1}, {1, -1}, {-1, 1}, {-1, -1}}
local ST = {{1, 0}, {-1, 0}, {0, 1}, {0, -1}}

local seed = 1234567
local function lcg()
    seed = (seed * 48271) % 2147483647
    return seed
end
local function rnd()
    return (lcg() % 67108864) * 1048576 + (lcg() % 1048576) + 1
end

local Z = {}
for i = 1, 12 do
    Z[i] = {}
    for sq = 1, 64 do
        Z[i][sq] = rnd()
    end
end
local ZS = rnd()
local ZC = {rnd(), rnd(), rnd(), rnd()}
local ZE = {}
for f = 1, 8 do
    ZE[f] = rnd()
end

local PIECES = {[true] = {}, [false] = {}}
for t, idx in pairs(PIDX) do
    PIECES[true][t] = {t = t, w = true, i = idx}
    PIECES[false][t] = {t = t, w = false, i = idx + 6}
end

local function piece(t, w)
    return PIECES[w][t]
end

local function inb(r, f)
    return r >= 1 and r <= 8 and f >= 1 and f <= 8
end

local function sameMove(a, b)
    return a.fr == b.fr and a.ff == b.ff and a.tr == b.tr and a.tf == b.tf and a.promo == b.promo
end

local function attacked(b, r, f, byWhite)
    local pr = r - (byWhite and 1 or -1)
    if pr >= 1 and pr <= 8 then
        for df = -1, 1, 2 do
            local pf = f + df
            if pf >= 1 and pf <= 8 then
                local p = b[pr][pf]
                if p and p.t == "P" and p.w == byWhite then
                    return true
                end
            end
        end
    end
    for _, d in ipairs(KN) do
        local rr, ff = r + d[1], f + d[2]
        if inb(rr, ff) then
            local p = b[rr][ff]
            if p and p.t == "N" and p.w == byWhite then
                return true
            end
        end
    end
    for _, d in ipairs(KG) do
        local rr, ff = r + d[1], f + d[2]
        if inb(rr, ff) then
            local p = b[rr][ff]
            if p and p.t == "K" and p.w == byWhite then
                return true
            end
        end
    end
    for _, d in ipairs(DG) do
        local rr, ff = r + d[1], f + d[2]
        while inb(rr, ff) do
            local p = b[rr][ff]
            if p then
                if p.w == byWhite and (p.t == "B" or p.t == "Q") then
                    return true
                end
                break
            end
            rr = rr + d[1]
            ff = ff + d[2]
        end
    end
    for _, d in ipairs(ST) do
        local rr, ff = r + d[1], f + d[2]
        while inb(rr, ff) do
            local p = b[rr][ff]
            if p then
                if p.w == byWhite and (p.t == "R" or p.t == "Q") then
                    return true
                end
                break
            end
            rr = rr + d[1]
            ff = ff + d[2]
        end
    end
    return false
end

local function push(out, fr, ff, tr, tf, cv, promo, ep, castle)
    out[#out + 1] = {fr = fr, ff = ff, tr = tr, tf = tf, cv = cv, promo = promo, ep = ep, castle = castle}
end

local function gen(s, capsOnly)
    local b = s.board
    local white = s.white
    local out = {}
    for r = 1, 8 do
        for f = 1, 8 do
            local p = b[r][f]
            if p and p.w == white then
                local t = p.t
                if t == "P" then
                    local dir = white and 1 or -1
                    local last = white and 8 or 1
                    local startR = white and 2 or 7
                    local nr = r + dir
                    if nr >= 1 and nr <= 8 then
                        if not b[nr][f] then
                            if nr == last then
                                for _, pt in ipairs(PROMO) do
                                    push(out, r, f, nr, f, 0, pt)
                                end
                            elseif not capsOnly then
                                push(out, r, f, nr, f, 0)
                                if r == startR and not b[r + 2 * dir][f] then
                                    push(out, r, f, r + 2 * dir, f, 0)
                                end
                            end
                        end
                        for df = -1, 1, 2 do
                            local nf = f + df
                            if nf >= 1 and nf <= 8 then
                                local tg = b[nr][nf]
                                if tg and tg.w ~= white then
                                    if nr == last then
                                        for _, pt in ipairs(PROMO) do
                                            push(out, r, f, nr, nf, VAL[tg.t], pt)
                                        end
                                    else
                                        push(out, r, f, nr, nf, VAL[tg.t])
                                    end
                                elseif not tg and s.ep and s.ep[1] == nr and s.ep[2] == nf then
                                    push(out, r, f, nr, nf, 100, nil, true)
                                end
                            end
                        end
                    end
                elseif t == "N" or t == "K" then
                    local dirs = t == "N" and KN or KG
                    for _, d in ipairs(dirs) do
                        local nr, nf = r + d[1], f + d[2]
                        if inb(nr, nf) then
                            local tg = b[nr][nf]
                            if not tg then
                                if not capsOnly then
                                    push(out, r, f, nr, nf, 0)
                                end
                            elseif tg.w ~= white then
                                push(out, r, f, nr, nf, VAL[tg.t])
                            end
                        end
                    end
                    if t == "K" and not capsOnly then
                        local hr = white and 1 or 8
                        if r == hr and f == 5 then
                            local ks = white and s.wK or s.bK
                            local qs = white and s.wQ or s.bQ
                            if (ks or qs) and not attacked(b, hr, 5, not white) then
                                if ks then
                                    local rk = b[hr][8]
                                    if rk and rk.t == "R" and rk.w == white and not b[hr][6] and not b[hr][7]
                                        and not attacked(b, hr, 6, not white) and not attacked(b, hr, 7, not white) then
                                        push(out, hr, 5, hr, 7, 0, nil, nil, "K")
                                    end
                                end
                                if qs then
                                    local rk = b[hr][1]
                                    if rk and rk.t == "R" and rk.w == white and not b[hr][2] and not b[hr][3] and not b[hr][4]
                                        and not attacked(b, hr, 4, not white) and not attacked(b, hr, 3, not white) then
                                        push(out, hr, 5, hr, 3, 0, nil, nil, "Q")
                                    end
                                end
                            end
                        end
                    end
                else
                    local dirs = t == "B" and DG or (t == "R" and ST or KG)
                    for _, d in ipairs(dirs) do
                        local nr, nf = r + d[1], f + d[2]
                        while inb(nr, nf) do
                            local tg = b[nr][nf]
                            if not tg then
                                if not capsOnly then
                                    push(out, r, f, nr, nf, 0)
                                end
                            else
                                if tg.w ~= white then
                                    push(out, r, f, nr, nf, VAL[tg.t])
                                end
                                break
                            end
                            nr = nr + d[1]
                            nf = nf + d[2]
                        end
                    end
                end
            end
        end
    end
    return out
end

local function make(s, m)
    local b = s.board
    local p = b[m.fr][m.ff]
    local h = s.h
    local u = {p = p, cap = b[m.tr][m.tf], ep = s.ep, wK = s.wK, wQ = s.wQ, bK = s.bK, bQ = s.bQ, h = h, half = s.half}
    local fsq = (m.fr - 1) * 8 + m.ff
    local tsq = (m.tr - 1) * 8 + m.tf
    h = h - Z[p.i][fsq]
    if m.ep then
        u.cap = b[m.fr][m.tf]
        b[m.fr][m.tf] = nil
        h = h - Z[u.cap.i][(m.fr - 1) * 8 + m.tf]
    elseif u.cap then
        h = h - Z[u.cap.i][tsq]
    end
    b[m.fr][m.ff] = nil
    local np = p
    if m.promo then
        np = piece(m.promo, p.w)
    end
    b[m.tr][m.tf] = np
    h = h + Z[np.i][tsq]
    if m.castle == "K" then
        local rk = b[m.fr][8]
        b[m.fr][6] = rk
        b[m.fr][8] = nil
        h = h - Z[rk.i][(m.fr - 1) * 8 + 8] + Z[rk.i][(m.fr - 1) * 8 + 6]
    elseif m.castle == "Q" then
        local rk = b[m.fr][1]
        b[m.fr][4] = rk
        b[m.fr][1] = nil
        h = h - Z[rk.i][(m.fr - 1) * 8 + 1] + Z[rk.i][(m.fr - 1) * 8 + 4]
    end
    local wK, wQ, bK, bQ = s.wK, s.wQ, s.bK, s.bQ
    if p.t == "K" then
        local k = s.king[p.w]
        u.kr, u.kf = k[1], k[2]
        k[1], k[2] = m.tr, m.tf
        if p.w then
            wK = false
            wQ = false
        else
            bK = false
            bQ = false
        end
    end
    for i = 1, 2 do
        local r, f
        if i == 1 then
            r, f = m.fr, m.ff
        else
            r, f = m.tr, m.tf
        end
        if r == 1 then
            if f == 1 then wQ = false elseif f == 8 then wK = false end
        elseif r == 8 then
            if f == 1 then bQ = false elseif f == 8 then bK = false end
        end
    end
    if s.wK and not wK then h = h - ZC[1] end
    if s.wQ and not wQ then h = h - ZC[2] end
    if s.bK and not bK then h = h - ZC[3] end
    if s.bQ and not bQ then h = h - ZC[4] end
    s.wK, s.wQ, s.bK, s.bQ = wK, wQ, bK, bQ
    if s.ep then
        h = h - ZE[s.ep[2]]
    end
    if p.t == "P" and math.abs(m.tr - m.fr) == 2 then
        s.ep = {(m.fr + m.tr) // 2, m.ff}
        h = h + ZE[m.ff]
    else
        s.ep = nil
    end
    if s.white then
        h = h + ZS
    else
        h = h - ZS
    end
    s.white = not s.white
    if p.t == "P" or u.cap then
        s.half = 0
    else
        s.half = s.half + 1
    end
    s.n = s.n + 1
    s.hist[s.n] = h
    s.h = h
    return u
end

local function unmake(s, m, u)
    local b = s.board
    s.white = not s.white
    b[m.fr][m.ff] = u.p
    if m.ep then
        b[m.tr][m.tf] = nil
        b[m.fr][m.tf] = u.cap
    else
        b[m.tr][m.tf] = u.cap
    end
    if m.castle == "K" then
        b[m.fr][8] = b[m.fr][6]
        b[m.fr][6] = nil
    elseif m.castle == "Q" then
        b[m.fr][1] = b[m.fr][4]
        b[m.fr][4] = nil
    end
    if u.kr then
        local k = s.king[u.p.w]
        k[1], k[2] = u.kr, u.kf
    end
    s.ep = u.ep
    s.wK, s.wQ, s.bK, s.bQ = u.wK, u.wQ, u.bK, u.bQ
    s.h = u.h
    s.half = u.half
    s.n = s.n - 1
end

local function makeNull(s)
    local u = {ep = s.ep, h = s.h, half = s.half}
    local h = s.h
    if s.ep then
        h = h - ZE[s.ep[2]]
        s.ep = nil
    end
    if s.white then
        h = h + ZS
    else
        h = h - ZS
    end
    s.white = not s.white
    s.half = s.half + 1
    s.n = s.n + 1
    s.hist[s.n] = h
    s.h = h
    return u
end

local function unmakeNull(s, u)
    s.white = not s.white
    s.ep = u.ep
    s.h = u.h
    s.half = u.half
    s.n = s.n - 1
end

local function legal(s, capsOnly)
    local pseudo = gen(s, capsOnly)
    local out = {}
    local mover = s.white
    for _, m in ipairs(pseudo) do
        local u = make(s, m)
        local k = s.king[mover]
        if not attacked(s.board, k[1], k[2], not mover) then
            out[#out + 1] = m
        end
        unmake(s, m, u)
    end
    return out
end

local function inCheck(s, white)
    local k = s.king[white]
    return attacked(s.board, k[1], k[2], not white)
end

local function fullHash(s)
    local h = 0
    for r = 1, 8 do
        for f = 1, 8 do
            local p = s.board[r][f]
            if p then
                h = h + Z[p.i][(r - 1) * 8 + f]
            end
        end
    end
    if not s.white then h = h + ZS end
    if s.wK then h = h + ZC[1] end
    if s.wQ then h = h + ZC[2] end
    if s.bK then h = h + ZC[3] end
    if s.bQ then h = h + ZC[4] end
    if s.ep then h = h + ZE[s.ep[2]] end
    return h
end

local function repeated(s)
    local h = s.h
    local lim = s.n - s.half
    if lim < 1 then
        lim = 1
    end
    for i = s.n - 2, lim, -2 do
        if s.hist[i] == h then
            return true
        end
    end
    return false
end

local fW, fB, wMin, bMax = {}, {}, {}, {}
local PR, PF, PC = {}, {}, {}
local RR, RF, RC = {}, {}, {}

local function shield(b, kr, kf, white)
    local home
    if white then
        home = kr <= 2
    else
        home = kr >= 7
    end
    if not home then
        return 0
    end
    local dir = white and 1 or -1
    local sc = 0
    for f = kf - 1, kf + 1 do
        if f >= 1 and f <= 8 then
            local r1 = kr + dir
            local r2 = kr + 2 * dir
            local p1 = b[r1] and b[r1][f]
            if p1 and p1.t == "P" and p1.w == white then
                sc = sc + 10
            else
                local p2 = b[r2] and b[r2][f]
                if p2 and p2.t == "P" and p2.w == white then
                    sc = sc + 5
                end
            end
        end
    end
    return sc
end

local function evaluate(s)
    local b = s.board
    for f = 0, 9 do
        fW[f] = 0
        fB[f] = 0
        wMin[f] = 9
        bMax[f] = 0
    end
    local np, nr = 0, 0
    local mat, phase = 0, 0
    local wBish, bBish = 0, 0
    local heavy, minor = 0, 0
    for r = 1, 8 do
        local row = b[r]
        for f = 1, 8 do
            local p = row[f]
            if p then
                local t = p.t
                if t ~= "K" then
                    phase = phase + PHASE[t]
                    if t == "N" or t == "B" then
                        minor = minor + 1
                    else
                        heavy = heavy + 1
                    end
                    if p.w then
                        mat = mat + VAL[t] + PST[t][r][f]
                        if t == "P" then
                            fW[f] = fW[f] + 1
                            if r < wMin[f] then wMin[f] = r end
                            np = np + 1
                            PR[np], PF[np], PC[np] = r, f, true
                        elseif t == "B" then
                            wBish = wBish + 1
                        elseif t == "R" then
                            nr = nr + 1
                            RR[nr], RF[nr], RC[nr] = r, f, true
                        end
                    else
                        mat = mat - VAL[t] - PST[t][9 - r][f]
                        if t == "P" then
                            fB[f] = fB[f] + 1
                            if r > bMax[f] then bMax[f] = r end
                            np = np + 1
                            PR[np], PF[np], PC[np] = r, f, false
                        elseif t == "B" then
                            bBish = bBish + 1
                        elseif t == "R" then
                            nr = nr + 1
                            RR[nr], RF[nr], RC[nr] = r, f, false
                        end
                    end
                end
            end
        end
    end
    if heavy == 0 and minor <= 1 then
        return 0
    end
    if phase > 24 then
        phase = 24
    end
    local wk, bk = s.king[true], s.king[false]
    local mgK = PST.K[wk[1]][wk[2]] - PST.K[9 - bk[1]][bk[2]]
    local egK = KEG[wk[1]][wk[2]] - KEG[9 - bk[1]][bk[2]]
    local score = mat + (mgK * phase + egK * (24 - phase)) // 24
    score = score + ((shield(b, wk[1], wk[2], true) - shield(b, bk[1], bk[2], false)) * phase) // 24
    if wBish >= 2 then score = score + 30 end
    if bBish >= 2 then score = score - 30 end
    for i = 1, np do
        local r, f = PR[i], PF[i]
        if PC[i] then
            if fW[f] > 1 then score = score - 8 end
            if fW[f - 1] == 0 and fW[f + 1] == 0 then score = score - 12 end
            if bMax[f - 1] <= r and bMax[f] <= r and bMax[f + 1] <= r then
                score = score + (PASS[r] * (48 - phase)) // 24
            end
        else
            if fB[f] > 1 then score = score + 8 end
            if fB[f - 1] == 0 and fB[f + 1] == 0 then score = score + 12 end
            if wMin[f - 1] >= r and wMin[f] >= r and wMin[f + 1] >= r then
                score = score - (PASS[9 - r] * (48 - phase)) // 24
            end
        end
    end
    for i = 1, nr do
        local f = RF[i]
        if RC[i] then
            if fW[f] == 0 then
                if fB[f] == 0 then score = score + 20 else score = score + 10 end
            end
        else
            if fB[f] == 0 then
                if fW[f] == 0 then score = score - 20 else score = score - 10 end
            end
        end
    end
    if s.white then
        return score + 10
    end
    return -score + 10
end

local function order(s, moves, ttm, ply, ctx)
    local b = s.board
    local k1, k2
    local side = s.white and 0 or 4096
    if ctx then
        local k = ctx.killers[ply]
        if k then
            k1, k2 = k[1], k[2]
        end
    end
    for _, m in ipairs(moves) do
        local sc
        if ttm and sameMove(m, ttm) then
            sc = 5000000
        elseif m.cv > 0 or m.promo then
            sc = 1000000 + m.cv * 10 - VAL[b[m.fr][m.ff].t] // 10
            if m.promo then
                sc = sc + VAL[m.promo] * 10
            end
        elseif k1 and sameMove(m, k1) then
            sc = 900000
        elseif k2 and sameMove(m, k2) then
            sc = 899999
        elseif ctx then
            sc = ctx.history[side + ((m.fr - 1) * 8 + m.ff - 1) * 64 + (m.tr - 1) * 8 + m.tf] or 0
            if sc > 800000 then
                sc = 800000
            end
        else
            sc = 0
        end
        m.sc = sc
    end
    table.sort(moves, function(a, c)
        return a.sc > c.sc
    end)
end

local function hasNonPawn(s)
    local b = s.board
    local w = s.white
    for r = 1, 8 do
        local row = b[r]
        for f = 1, 8 do
            local p = row[f]
            if p and p.w == w and p.t ~= "P" and p.t ~= "K" then
                return true
            end
        end
    end
    return false
end

local function quiesce(s, alpha, beta, ply, ctx, qd)
    ctx.nodes = ctx.nodes + 1
    if ctx.nodes % 2048 == 0 and os.clock() > ctx.deadline then
        ctx.stop = true
    end
    if ctx.stop then
        return 0
    end
    local checked = inCheck(s, s.white)
    local moves
    local stand = -INF
    if checked and qd < 6 then
        moves = legal(s, false)
        if #moves == 0 then
            return -MATE + ply
        end
    else
        stand = evaluate(s)
        if stand >= beta then
            return stand
        end
        if stand > alpha then
            alpha = stand
        end
        if qd >= 10 then
            return stand
        end
        moves = legal(s, true)
    end
    order(s, moves, nil, ply, nil)
    local best = stand
    for _, m in ipairs(moves) do
        if checked or m.promo or stand + m.cv + 200 >= alpha then
            local u = make(s, m)
            local score = -quiesce(s, -beta, -alpha, ply + 1, ctx, qd + 1)
            unmake(s, m, u)
            if ctx.stop then
                return 0
            end
            if score > best then
                best = score
            end
            if score > alpha then
                alpha = score
                if alpha >= beta then
                    break
                end
            end
        end
    end
    return best
end

local function negamax(s, depth, alpha, beta, ply, ctx, nullOk)
    ctx.nodes = ctx.nodes + 1
    if ctx.nodes % 2048 == 0 and os.clock() > ctx.deadline then
        ctx.stop = true
    end
    if ctx.stop then
        return 0
    end
    if s.half >= 100 or repeated(s) then
        return 0
    end
    local checked = inCheck(s, s.white)
    if checked and ply < 24 then
        depth = depth + 1
    end
    if depth <= 0 then
        return quiesce(s, alpha, beta, ply, ctx, 0)
    end
    local alpha0 = alpha
    local e = ctx.tt[s.h]
    local ttm
    if e then
        ttm = e.m
        if e.d >= depth then
            local sc = e.s
            if sc > MATE - 200 then
                sc = sc - ply
            elseif sc < -MATE + 200 then
                sc = sc + ply
            end
            if e.f == 1 then
                return sc
            elseif e.f == 2 and sc >= beta then
                return sc
            elseif e.f == 3 and sc <= alpha then
                return sc
            end
        end
    end
    local pv = beta - alpha > 1
    if nullOk and not checked and not pv and depth >= 3 and evaluate(s) >= beta and hasNonPawn(s) then
        local u = makeNull(s)
        local R = depth >= 6 and 3 or 2
        local sc = -negamax(s, depth - 1 - R, -beta, -beta + 1, ply + 1, ctx, false)
        unmakeNull(s, u)
        if ctx.stop then
            return 0
        end
        if sc >= beta then
            if sc > MATE - 200 then
                return beta
            end
            return sc
        end
    end
    local moves = legal(s, false)
    if #moves == 0 then
        if checked then
            return -MATE + ply
        end
        return 0
    end
    order(s, moves, ttm, ply, ctx)
    local best = -INF
    local bestMove
    for i, m in ipairs(moves) do
        local quiet = m.cv == 0 and not m.promo
        local mover = s.white
        local u = make(s, m)
        local sc
        if i == 1 then
            sc = -negamax(s, depth - 1, -beta, -alpha, ply + 1, ctx, true)
        else
            local red = 0
            if depth >= 3 and i > 4 and quiet and not checked then
                red = (i > 8 and depth >= 5) and 2 or 1
            end
            sc = -negamax(s, depth - 1 - red, -alpha - 1, -alpha, ply + 1, ctx, true)
            if sc > alpha and red > 0 then
                sc = -negamax(s, depth - 1, -alpha - 1, -alpha, ply + 1, ctx, true)
            end
            if sc > alpha and sc < beta then
                sc = -negamax(s, depth - 1, -beta, -alpha, ply + 1, ctx, true)
            end
        end
        unmake(s, m, u)
        if ctx.stop then
            return 0
        end
        if sc > best then
            best = sc
            bestMove = m
        end
        if sc > alpha then
            alpha = sc
            if alpha >= beta then
                if quiet then
                    local k = ctx.killers[ply]
                    if not k then
                        ctx.killers[ply] = {m}
                    elseif not sameMove(k[1], m) then
                        k[2] = k[1]
                        k[1] = m
                    end
                    local key = (mover and 0 or 4096) + ((m.fr - 1) * 8 + m.ff - 1) * 64 + (m.tr - 1) * 8 + m.tf
                    ctx.history[key] = (ctx.history[key] or 0) + depth * depth
                end
                break
            end
        end
    end
    local flag = 1
    if best <= alpha0 then
        flag = 3
    elseif best >= beta then
        flag = 2
    end
    local store = best
    if store > MATE - 200 then
        store = store + ply
    elseif store < -MATE + 200 then
        store = store - ply
    end
    if not e then
        ctx.tt[s.h] = {d = depth, f = flag, s = store, m = bestMove}
        ctx.ttn = ctx.ttn + 1
    elseif depth >= e.d then
        e.d, e.f, e.s, e.m = depth, flag, store, bestMove
    end
    return best
end

function Engine.fromBoard(grid, whiteToMove, opts)
    opts = opts or {}
    local b = {}
    local s = {board = b, white = whiteToMove and true or false, ep = opts.ep, king = {[true] = {0, 0}, [false] = {0, 0}}}
    for r = 1, 8 do
        b[r] = {}
        for f = 1, 8 do
            local c = grid[r] and grid[r][f]
            if c then
                local t = c.t or c.type
                local w = c.w
                if w == nil then
                    w = c.white
                end
                w = w and true or false
                b[r][f] = piece(t, w)
                if t == "K" then
                    s.king[w] = {r, f}
                end
            end
        end
    end
    if s.king[true][1] == 0 or s.king[false][1] == 0 then
        error("rei ausente no tabuleiro")
    end
    local function has(r, f, t, w)
        local p = b[r][f]
        return p ~= nil and p.t == t and p.w == w
    end
    local c = opts.castle
    if c then
        s.wK, s.wQ, s.bK, s.bQ = c.wK == true, c.wQ == true, c.bK == true, c.bQ == true
    else
        s.wK = has(1, 5, "K", true) and has(1, 8, "R", true)
        s.wQ = has(1, 5, "K", true) and has(1, 1, "R", true)
        s.bK = has(8, 5, "K", false) and has(8, 8, "R", false)
        s.bQ = has(8, 5, "K", false) and has(8, 1, "R", false)
    end
    s.half = opts.half or 0
    s.h = fullHash(s)
    s.hist = {s.h}
    s.n = 1
    return s
end

function Engine.fromFEN(fen)
    local placement, side, castle, ep, half = fen:match("^(%S+)%s+(%S+)%s*(%S*)%s*(%S*)%s*(%d*)")
    local grid = {}
    for r = 1, 8 do
        grid[r] = {}
    end
    local r, f = 8, 1
    for ch in placement:gmatch(".") do
        if ch == "/" then
            r = r - 1
            f = 1
        elseif ch:match("%d") then
            f = f + tonumber(ch)
        else
            grid[r][f] = {t = ch:upper(), w = ch:match("%u") ~= nil}
            f = f + 1
        end
    end
    local epSq
    if ep and ep ~= "" and ep ~= "-" then
        epSq = {tonumber(ep:sub(2, 2)), ep:byte(1) - 96}
    end
    return Engine.fromBoard(grid, side == "w", {
        castle = {
            wK = castle:find("K", 1, true) ~= nil,
            wQ = castle:find("Q", 1, true) ~= nil,
            bK = castle:find("k", 1, true) ~= nil,
            bQ = castle:find("q", 1, true) ~= nil,
        },
        ep = epSq,
        half = tonumber(half) or 0,
    })
end

function Engine.new()
    return Engine.fromFEN("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0")
end

function Engine.fen(s)
    local rows = {}
    for r = 8, 1, -1 do
        local row, empty = "", 0
        for f = 1, 8 do
            local p = s.board[r][f]
            if p then
                if empty > 0 then
                    row = row .. empty
                    empty = 0
                end
                row = row .. (p.w and p.t or p.t:lower())
            else
                empty = empty + 1
            end
        end
        if empty > 0 then
            row = row .. empty
        end
        rows[#rows + 1] = row
    end
    local c = (s.wK and "K" or "") .. (s.wQ and "Q" or "") .. (s.bK and "k" or "") .. (s.bQ and "q" or "")
    if c == "" then
        c = "-"
    end
    local ep = s.ep and (string.char(96 + s.ep[2]) .. s.ep[1]) or "-"
    return table.concat(rows, "/") .. " " .. (s.white and "w" or "b") .. " " .. c .. " " .. ep .. " " .. s.half .. " 1"
end

function Engine.legalMoves(s)
    return legal(s, false)
end

function Engine.inCheck(s)
    return inCheck(s, s.white)
end

function Engine.status(s)
    if #legal(s, false) == 0 then
        if inCheck(s, s.white) then
            return "checkmate"
        end
        return "stalemate"
    end
    if s.half >= 100 then
        return "draw50"
    end
    if repeated(s) then
        return "repetition"
    end
    return "playing"
end

function Engine.play(s, m)
    make(s, m)
end

function Engine.toSquare(rank, file)
    return string.char(96 + file) .. tostring(rank)
end

function Engine.moveToString(m)
    return Engine.toSquare(m.fr, m.ff) .. Engine.toSquare(m.tr, m.tf) .. (m.promo and m.promo:lower() or "")
end

function Engine.parseMove(s, str)
    for _, m in ipairs(legal(s, false)) do
        if Engine.moveToString(m) == str then
            return m
        end
    end
    return nil
end

function Engine.toSAN(s, m)
    local san
    if m.castle == "K" then
        san = "O-O"
    elseif m.castle == "Q" then
        san = "O-O-O"
    else
        local p = s.board[m.fr][m.ff]
        local isCap = m.cv > 0
        if p.t == "P" then
            san = isCap and (string.char(96 + m.ff) .. "x") or ""
            san = san .. Engine.toSquare(m.tr, m.tf)
        else
            san = p.t
            local other, sameFile, sameRank = false, false, false
            for _, o in ipairs(legal(s, false)) do
                if o.tr == m.tr and o.tf == m.tf and not (o.fr == m.fr and o.ff == m.ff) and s.board[o.fr][o.ff] == p then
                    other = true
                    if o.ff == m.ff then sameFile = true end
                    if o.fr == m.fr then sameRank = true end
                end
            end
            if other then
                if not sameFile then
                    san = san .. string.char(96 + m.ff)
                elseif not sameRank then
                    san = san .. m.fr
                else
                    san = san .. string.char(96 + m.ff) .. m.fr
                end
            end
            san = san .. (isCap and "x" or "") .. Engine.toSquare(m.tr, m.tf)
        end
        if m.promo then
            san = san .. "=" .. m.promo
        end
    end
    local u = make(s, m)
    if inCheck(s, s.white) then
        if #legal(s, false) == 0 then
            san = san .. "#"
        else
            san = san .. "+"
        end
    end
    unmake(s, m, u)
    return san
end

function Engine.hash(s)
    return s.h
end

function Engine.fullHash(s)
    return fullHash(s)
end

function Engine.perft(s, depth)
    if depth == 0 then
        return 1
    end
    local total = 0
    for _, m in ipairs(legal(s, false)) do
        local u = make(s, m)
        total = total + Engine.perft(s, depth - 1)
        unmake(s, m, u)
    end
    return total
end

local function extractPV(s, ctx, maxLen)
    local pv, undo = {}, {}
    for _ = 1, maxLen do
        local e = ctx.tt[s.h]
        if not e or not e.m or e.f == 3 then
            break
        end
        local found
        for _, m in ipairs(legal(s, false)) do
            if sameMove(m, e.m) then
                found = m
                break
            end
        end
        if not found then
            break
        end
        pv[#pv + 1] = Engine.moveToString(found)
        undo[#undo + 1] = {found, make(s, found)}
    end
    for i = #undo, 1, -1 do
        unmake(s, undo[i][1], undo[i][2])
    end
    return pv
end

function Engine.bestMove(s, opts)
    opts = opts or {}
    local maxDepth = opts.depth or 8
    local startT = os.clock()
    local limit = opts.time or 2
    local ctx = {nodes = 0, stop = false, deadline = startT + limit, tt = {}, ttn = 0, killers = {}, history = {}}
    local moves = legal(s, false)
    if #moves == 0 then
        if inCheck(s, s.white) then
            return nil, s.white and -MATE or MATE, 0, 0, {}
        end
        return nil, 0, 0, 0, {}
    end
    if #moves == 1 then
        maxDepth = math.min(maxDepth, 2)
    end
    local best, bestScore, reached, prevBest = moves[1], 0, 0, nil
    local function rootSearch(d, alpha, beta)
        order(s, moves, prevBest, 0, ctx)
        local rb, rs = nil, -INF
        for i, m in ipairs(moves) do
            local u = make(s, m)
            local sc
            if i == 1 then
                sc = -negamax(s, d - 1, -beta, -alpha, 1, ctx, true)
            else
                sc = -negamax(s, d - 1, -alpha - 1, -alpha, 1, ctx, true)
                if sc > alpha and sc < beta then
                    sc = -negamax(s, d - 1, -beta, -alpha, 1, ctx, true)
                end
            end
            unmake(s, m, u)
            if ctx.stop then
                return nil, nil
            end
            if sc > rs then
                rs = sc
                rb = m
            end
            if sc > alpha then
                alpha = sc
            end
        end
        ctx.tt[s.h] = {d = d, f = 1, s = rs, m = rb}
        return rb, rs
    end
    for d = 1, maxDepth do
        local a, bt = -INF, INF
        if d >= 4 then
            a = bestScore - 40
            bt = bestScore + 40
        end
        local mv, sc
        while true do
            mv, sc = rootSearch(d, a, bt)
            if ctx.stop then
                break
            end
            if sc <= a and a > -INF then
                a = -INF
            elseif sc >= bt and bt < INF then
                bt = INF
            else
                break
            end
        end
        if ctx.stop or not mv then
            break
        end
        best, bestScore, reached, prevBest = mv, sc, d, mv
        if math.abs(bestScore) > MATE - 100 then
            break
        end
        if os.clock() - startT > limit * 0.5 then
            break
        end
    end
    local pv = extractPV(s, ctx, 12)
    local white = bestScore
    if not s.white then
        white = -bestScore
    end
    return best, white, reached, ctx.nodes, pv
end

return Engine
