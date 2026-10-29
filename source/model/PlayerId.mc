module PlayerId {
    const ME = 0;
    const PARTNER = 1;
    const OP_1 = 2;
    const OP_2 = 3;
    const DOUBLE_FAULT = 4;

    function isOurTeam(player) {
        return player == ME || player == PARTNER;
    }

    function label(player) {
        if (player == ME) {
            return "ME";
        }
        if (player == PARTNER) {
            return "P";
        }
        if (player == OP_1) {
            return "OP 1";
        }
        if (player == OP_2) {
            return "OP 2";
        }
        return "DF";
    }

    function serveNotice(player) {
        if (player == ME) {
            return "YOU SERVE";
        }
        if (player == PARTNER) {
            return "P TO SERVE";
        }
        if (player == OP_1) {
            return "OP 1 TO SERVE";
        }
        return "OP 2 TO SERVE";
    }

    function marker(player) {
        if (player == ME) {
            return "M";
        }
        if (player == PARTNER) {
            return "P";
        }
        if (player == OP_1) {
            return "1";
        }
        return "2";
    }
}
