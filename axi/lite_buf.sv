
module axi_lite_buf #(
    parameter DEPTH         = 1,
    parameter ADDR_WIDTH    = 48,
    parameter DATA_WIDTH    = 64
) (
    axi_lite_channel.slave  master,
    axi_lite_channel.master slave
);

    localparam STRB_WIDTH = DATA_WIDTH / 8;

    // Static checks of interface matching
    initial
        assert (ADDR_WIDTH == master.ADDR_WIDTH && ADDR_WIDTH == slave.ADDR_WIDTH &&
                DATA_WIDTH == master.DATA_WIDTH && DATA_WIDTH == slave.DATA_WIDTH)
        else $fatal(1, "Parameter mismatch");

    //
    // AW channel
    //

    typedef struct packed {
        logic [ADDR_WIDTH-1:0] addr;
        prot_t                 prot;
    } ax_pack_t;

    fifo #(
        .TYPE  (ax_pack_t),
        .DEPTH (DEPTH)
    ) awfifo (
        .clk     (master.clk),
        .rstn    (master.rstn),
        .w_valid (master.aw_valid),
        .w_ready (master.aw_ready),
        .w_data  ('{master.aw_addr, master.aw_prot}),
        .r_valid (slave.aw_valid),
        .r_ready (slave.aw_ready),
        .r_data  ('{slave.aw_addr, slave.aw_prot})
    );

    //
    // W channel
    //

    typedef struct packed {
        logic [DATA_WIDTH-1:0] data;
        logic [STRB_WIDTH-1:0] strb;
    } w_pack_t;

    fifo #(
        .TYPE  (w_pack_t),
        .DEPTH (DEPTH)
    ) wfifo (
        .clk     (master.clk),
        .rstn    (master.rstn),
        .w_valid (master.w_valid),
        .w_ready (master.w_ready),
        .w_data  ('{master.w_data, master.w_strb}),
        .r_valid (slave.w_valid),
        .r_ready (slave.w_ready),
        .r_data  ('{slave.w_data, slave.w_strb})
    );

    //
    // B channel
    //

    fifo #(
        .TYPE  (resp_t),
        .DEPTH (DEPTH)
    ) bfifo (
        .clk     (master.clk),
        .rstn    (master.rstn),
        .w_valid (slave.b_valid),
        .w_ready (slave.b_ready),
        .w_data  (slave.b_resp),
        .r_valid (master.b_valid),
        .r_ready (master.b_ready),
        .r_data  (master.b_resp)
    );

    //
    // AR channel
    //

    fifo #(
        .TYPE  (ax_pack_t),
        .DEPTH (DEPTH)
    ) arfifo (
        .clk     (master.clk),
        .rstn    (master.rstn),
        .w_valid (master.ar_valid),
        .w_ready (master.ar_ready),
        .w_data  ('{master.ar_addr, master.ar_prot}),
        .r_valid (slave.ar_valid),
        .r_ready (slave.ar_ready),
        .r_data  ('{slave.ar_addr, slave.ar_prot})
    );

    //
    // R channel
    //

    typedef struct packed {
        logic [DATA_WIDTH-1:0] data;
        resp_t                 resp;
    } r_pack_t;

    fifo #(
        .TYPE  (r_pack_t),
        .DEPTH (DEPTH)
    ) rfifo (
        .clk     (master.clk),
        .rstn    (master.rstn),
        .w_valid (slave.r_valid),
        .w_ready (slave.r_ready),
        .w_data  ('{slave.r_data, slave.r_resp}),
        .r_valid (master.r_valid),
        .r_ready (master.r_ready),
        .r_data  ('{master.r_data, master.r_resp})
    );

endmodule
