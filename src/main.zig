const std = @import("std");
const c = @cImport(@cInclude("uv.h"));

test "loop" {
    const loop = try std.testing.allocator.create(c.uv_loop_t);
    defer std.testing.allocator.destroy(loop);

    try std.testing.expect(c.uv_loop_init(loop) == 0);
    try std.testing.expect(c.uv_run(loop, c.UV_RUN_DEFAULT) == 0);
}

test "async" {
    const State = struct {
        channel: c.uv_async_t,
        mutex: c.uv_mutex_t,
        thread: c.uv_thread_t,

        fn receiver(channel: [*c]c.uv_async_t) callconv(.C) void {
            c.uv_close(@ptrCast(channel), null);
        }

        fn sender(ptr: ?*anyopaque) callconv(.C) void {
            const state: *@This() = @ptrCast(@alignCast(ptr));
            _ = c.uv_async_send(&state.channel);
        }
    };

    var state: State = undefined;
    try std.testing.expect(c.uv_mutex_init(&state.mutex) == 0);
    try std.testing.expect(c.uv_async_init(c.uv_default_loop(), &state.channel, &State.receiver) == 0);
    try std.testing.expect(c.uv_thread_create(&state.thread, &State.sender, @ptrCast(&state)) == 0);

    try std.testing.expect(c.uv_run(c.uv_default_loop(), c.UV_RUN_DEFAULT) == 0);
}