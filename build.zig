const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib = b.addStaticLibrary(.{
        .name = "uv",
        .target = target,
        .optimize = optimize,
    });
    lib.linkLibC();
    lib.addCSourceFiles(&.{
        "vendor/src/fs-poll.c",
        "vendor/src/idna.c",
        "vendor/src/inet.c",
        "vendor/src/random.c",
        "vendor/src/strscpy.c",
        "vendor/src/strtok.c",
        "vendor/src/thread-common.c",
        "vendor/src/threadpool.c",
        "vendor/src/timer.c",
        "vendor/src/uv-common.c",
        "vendor/src/uv-data-getter-setters.c",
        "vendor/src/version.c",
    }, &.{});

    if (target.isWindows()) {
        lib.linkSystemLibrary("psapi");
        lib.linkSystemLibrary("user32");
        lib.linkSystemLibrary("advapi32");
        lib.linkSystemLibrary("iphlpapi");
        lib.linkSystemLibrary("userenv");
        lib.linkSystemLibrary("ws2_32");
        lib.linkSystemLibrary("dbghelp");
        lib.linkSystemLibrary("ole32");
        lib.linkSystemLibrary("uuid");

        lib.addCSourceFiles(&.{
            "vendor/src/win/async.c",
            "vendor/src/win/core.c",
            "vendor/src/win/detect-wakeup.c",
            "vendor/src/win/dl.c",
            "vendor/src/win/error.c",
            "vendor/src/win/fs.c",
            "vendor/src/win/fs-event.c",
            "vendor/src/win/getaddrinfo.c",
            "vendor/src/win/getnameinfo.c",
            "vendor/src/win/handle.c",
            "vendor/src/win/loop-watcher.c",
            "vendor/src/win/pipe.c",
            "vendor/src/win/thread.c",
            "vendor/src/win/poll.c",
            "vendor/src/win/process.c",
            "vendor/src/win/process-stdio.c",
            "vendor/src/win/signal.c",
            "vendor/src/win/snprintf.c",
            "vendor/src/win/stream.c",
            "vendor/src/win/tcp.c",
            "vendor/src/win/tty.c",
            "vendor/src/win/udp.c",
            "vendor/src/win/util.c",
            "vendor/src/win/winapi.c",
            "vendor/src/win/winsock.c",
        }, &.{});
    } else {
        if (target.abi != std.Target.Abi.android) {
            lib.linkSystemLibrary("pthread");
        }
        lib.addCSourceFiles(&.{
            "vendor/src/unix/async.c",
            "vendor/src/unix/core.c",
            "vendor/src/unix/dl.c",
            "vendor/src/unix/fs.c",
            "vendor/src/unix/getaddrinfo.c",
            "vendor/src/unix/getnameinfo.c",
            "vendor/src/unix/loop-watcher.c",
            "vendor/src/unix/loop.c",
            "vendor/src/unix/pipe.c",
            "vendor/src/unix/poll.c",
            "vendor/src/unix/process.c",
            "vendor/src/unix/random-devurandom.c",
            "vendor/src/unix/signal.c",
            "vendor/src/unix/stream.c",
            "vendor/src/unix/tcp.c",
            "vendor/src/unix/thread.c",
            "vendor/src/unix/tty.c",
            "vendor/src/unix/udp.c",
        }, &.{});
    }

    if (target.os_tag == std.Target.Os.Tag.aix) {
        lib.linkSystemLibrary("perfstat");
        lib.addCSourceFiles(&.{
            "vendor/src/unix/aix.c",
            "vendor/src/unix/aix-common.c",
        }, &.{});
    }

    if (target.abi == std.Target.Abi.android) {
        lib.linkSystemLibrary("dl");
        lib.addCSourceFiles(&.{
            "vendor/src/unix/linux.c",
            "vendor/src/unix/procfs-exepath.c",
            "vendor/src/unix/random-getentropy.c",
            "vendor/src/unix/random-getrandom.c",
            "vendor/src/unix/random-sysctl-linux.c",
        }, &.{});
    }

    if (target.isDarwin() or target.abi == std.Target.Abi.android or target.isLinux()) {
        lib.addCSourceFile(.{ .file = .{ .path = "vendor/src/unix/proctitle.c" }, .flags = &.{} });
    }

    if (target.isDragonFlyBSD() or target.isFreeBSD()) {
        lib.addCSourceFile(.{ .file = .{ .path = "vendor/src/unix/freebsd.c" }, .flags = &.{} });
    }

    if (target.isDragonFlyBSD() or target.isFreeBSD() or target.isNetBSD() or target.isOpenBSD()) {
        lib.addCSourceFiles(&.{
            "vendor/src/unix/posix-hrtime.c",
            "vendor/src/unix/bsd-proctitle.c",
        }, &.{});
    }

    if (target.isDarwin() or target.isDragonFlyBSD() or target.isFreeBSD() or target.isNetBSD() or target.isOpenBSD()) {
        lib.addCSourceFiles(&.{
            "vendor/src/unix/bsd-ifaddrs.c",
            "vendor/src/unix/kqueue.c",
        }, &.{});
    }

    if (target.isFreeBSD()) {
        lib.addCSourceFile(.{ .file = .{ .path = "vendor/src/unix/random-getrandom.c" }, .flags = &.{} });
    }

    if (target.isOpenBSD()) {
        lib.addCSourceFile(.{ .file = .{ .path = "vendor/src/unix/random-getentropy.c" }, .flags = &.{} });
    }

    if (target.isDarwin()) {
        lib.addCSourceFiles(&.{
            "vendor/src/unix/darwin-proctitle.c",
            "vendor/src/unix/darwin.c",
            "vendor/src/unix/fsevents.c",
        }, &.{});
    }

    if (target.getAbi().isGnu()) {
        lib.linkSystemLibrary("dl");
        lib.addCSourceFiles(&.{
            "vendor/src/unix/bsd-ifaddrs.c",
            "vendor/src/unix/no-fsevents.c",
            "vendor/src/unix/no-proctitle.c",
            "vendor/src/unix/posix-hrtime.c",
            "vendor/src/unix/posix-poll.c",
            "vendor/src/unix/hurd.c",
        }, &.{});
    }

    if (target.isLinux()) {
        lib.linkSystemLibrary("dl");
        lib.linkSystemLibrary("rt");
        lib.addCSourceFiles(&.{
            "vendor/src/unix/linux.c",
            "vendor/src/unix/procfs-exepath.c",
            "vendor/src/unix/random-getrandom.c",
            "vendor/src/unix/random-sysctl-linux.c",
        }, &.{});
    }

    if (target.isNetBSD()) {
        lib.linkSystemLibrary("kvm");
        lib.addCSourceFile(.{ .file = .{ .path = "vendor/src/unix/netbsd.c" }, .flags = &.{} });
    }

    if (target.isOpenBSD()) {
        lib.addCSourceFile(.{ .file = .{ .path = "vendor/src/unix/openbsd.c" }, .flags = &.{} });
    }

    if (target.os_tag == std.Target.Os.Tag.solaris) {
        lib.linkSystemLibrary("kstat");
        lib.linkSystemLibrary("nsl");
        lib.linkSystemLibrary("sendfile");
        lib.linkSystemLibrary("socket");
        lib.addCSourceFiles(&.{
            "vendor/src/unix/no-proctitle.c",
            "vendor/src/unix/sunos.c",
        }, &.{});
    }

    if (target.os_tag == std.Target.Os.Tag.haiku) {
        lib.linkSystemLibrary("bsd");
        lib.linkSystemLibrary("network");
        lib.addCSourceFiles(&.{
            "vendor/src/unix/haiku.c",
            "vendor/src/unix/bsd-ifaddrs.c",
            "vendor/src/unix/no-fsevents.c",
            "vendor/src/unix/no-proctitle.c",
            "vendor/src/unix/posix-hrtime.c",
            "vendor/src/unix/posix-poll.c",
        }, &.{});
    }

    if (target.abi == .cygnus or (target.isWindows() and target.getAbi().isGnu())) {
        lib.addCSourceFiles(&.{
            "vendor/src/unix/cygwin.c",
            "vendor/src/unix/bsd-ifaddrs.c",
            "vendor/src/unix/no-fsevents.c",
            "vendor/src/unix/no-proctitle.c",
            "vendor/src/unix/posix-hrtime.c",
            "vendor/src/unix/posix-poll.c",
            "vendor/src/unix/procfs-exepath.c",
            "vendor/src/unix/sysinfo-loadavg.c",
            "vendor/src/unix/sysinfo-memory.c",
        }, &.{});
    }

    lib.addIncludePath(.{ .path = "vendor/src" });
    lib.addIncludePath(.{ .path = "vendor/include" });
    lib.installHeadersDirectory("vendor/include", "");

    b.installArtifact(lib);

    const tests = b.addTest(.{
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });
    tests.linkLibrary(lib);

    const run_tests = b.addRunArtifact(tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_tests.step);
}
