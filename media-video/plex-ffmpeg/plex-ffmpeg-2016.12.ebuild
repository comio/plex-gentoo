# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit eutils flag-o-matic multilib multilib-minimal toolchain-funcs

DESCRIPTION="Plex Transcoder, a ffmpeg fork from Plex Inc."
HOMEPAGE="https://www.plex.tv/"

SRC_URI="http://files.plexapp.com/mfeingol/ffmpeg/plex-ffmpeg-2016-12.tgz"

SLOT="0"
LICENSE="
	!gpl? ( LGPL-2.1 )
	gpl? ( GPL-2 )
	amr? (
		gpl? ( GPL-3 )
		!gpl? ( LGPL-3 )
	)
	gmp? (
		gpl? ( GPL-3 )
		!gpl? ( LGPL-3 )
	)
	encode? (
		amrenc? (
			gpl? ( GPL-3 )
			!gpl? ( LGPL-3 )
		)
	)
	samba? ( GPL-3 )
"

KEYWORDS="~amd64 ~x86"

# Options to use as use_enable in the foo[:bar] form.
# This will feed configure with $(use_enable foo bar)
# or $(use_enable foo foo) if no :bar is set.
# foo is added to IUSE.
FFMPEG_FLAG_MAP=(
		+bzip2:bzlib cpudetection:runtime-cpudetect debug gcrypt gnutls gmp
		+gpl +hardcoded-tables +iconv lzma +network openssl +postproc
		samba:libsmbclient sdl:ffplay sdl:sdl2 +vaapi vdpau X:xlib xcb:libxcb
		xcb:libxcb-shm xcb:libxcb-xfixes +zlib
		# libavdevice options
		cdio:libcdio iec61883:libiec61883 ieee1394:libdc1394 libcaca openal
		opengl
		# indevs
		libv4l:libv4l2 pulseaudio:libpulse
		# decoders
		amr:libopencore-amrwb amr:libopencore-amrnb fdk:libfdk-aac
		jpeg2k:libopenjpeg bluray:libbluray celt:libcelt gme:libgme gsm:libgsm
		mmal modplug:libmodplug opus:libopus libilbc librtmp ssh:libssh
		schroedinger:libschroedinger speex:libspeex vorbis:libvorbis vpx:libvpx
		zvbi:libzvbi
		# libavfilter options
		bs2b:libbs2b chromaprint ebur128:libebur128 flite:libflite frei0r
		fribidi:libfribidi fontconfig ladspa libass truetype:libfreetype
		rubberband:librubberband zimg:libzimg
		# libswresample options
		libsoxr
		# Threads; we only support pthread for now but ffmpeg supports more
		+threads:pthreads
)

# Same as above but for encoders, i.e. they do something only with USE=encode.
FFMPEG_ENCODER_FLAG_MAP=(
	amrenc:libvo-amrwbenc mp3:libmp3lame
	kvazaar:libkvazaar nvenc:nvenc
	openh264:libopenh264 snappy:libsnappy theora:libtheora twolame:libtwolame
	wavpack:libwavpack webp:libwebp x264:libx264 x265:libx265 xvid:libxvid
)

IUSE="
	alsa doc +encode jack oss pic static-libs test v4l
	${FFMPEG_FLAG_MAP[@]%:*}
	${FFMPEG_ENCODER_FLAG_MAP[@]%:*}
"

# Strings for CPU features in the useflag[:configure_option] form
# if :configure_option isn't set, it will use 'useflag' as configure option
ARM_CPU_FEATURES=( armv5te armv6 armv6t2 neon armvfp:vfp )
MIPS_CPU_FEATURES=( mipsdspr1 mipsdspr2 mipsfpu )
PPC_CPU_FEATURES=( altivec )
X86_CPU_FEATURES_RAW=( 3dnow:amd3dnow 3dnowext:amd3dnowext aes:aesni avx:avx avx2:avx2 fma3:fma3 fma4:fma4 mmx:mmx mmxext:mmxext sse:sse sse2:sse2 sse3:sse3 ssse3:ssse3 sse4_1:sse4 sse4_2:sse42 xop:xop )
X86_CPU_FEATURES=( ${X86_CPU_FEATURES_RAW[@]/#/cpu_flags_x86_} )
X86_CPU_REQUIRED_USE="
	cpu_flags_x86_avx2? ( cpu_flags_x86_avx )
	cpu_flags_x86_fma4? ( cpu_flags_x86_avx )
	cpu_flags_x86_fma3? ( cpu_flags_x86_avx )
	cpu_flags_x86_xop?  ( cpu_flags_x86_avx )
	cpu_flags_x86_avx?  ( cpu_flags_x86_sse4_2 )
	cpu_flags_x86_aes? ( cpu_flags_x86_sse4_2 )
	cpu_flags_x86_sse4_2?  ( cpu_flags_x86_sse4_1 )
	cpu_flags_x86_sse4_1?  ( cpu_flags_x86_ssse3 )
	cpu_flags_x86_ssse3?  ( cpu_flags_x86_sse3 )
	cpu_flags_x86_sse3?  ( cpu_flags_x86_sse2 )
	cpu_flags_x86_sse2?  ( cpu_flags_x86_sse )
	cpu_flags_x86_sse?  ( cpu_flags_x86_mmxext )
	cpu_flags_x86_mmxext?  ( cpu_flags_x86_mmx )
	cpu_flags_x86_3dnowext?  ( cpu_flags_x86_3dnow )
	cpu_flags_x86_3dnow?  ( cpu_flags_x86_mmx )
"

IUSE="${IUSE}
	${ARM_CPU_FEATURES[@]%:*}
	${MIPS_CPU_FEATURES[@]%:*}
	${PPC_CPU_FEATURES[@]%:*}
	${X86_CPU_FEATURES[@]%:*}
"

CPU_REQUIRED_USE="
	${X86_CPU_REQUIRED_USE}
"

# "$(tc-arch):XXX" form where XXX_CPU_FEATURES are the cpu features that apply to
# $(tc-arch).
CPU_FEATURES_MAP="
	arm:ARM
	arm64:ARM
	mips:MIPS
	ppc:PPC
	ppc64:PPC
	x86:X86
	amd64:X86
"

FFTOOLS=( aviocat cws2fws ffescape ffeval ffhash fourcc2pixfmt graph2dot ismindex pktdumper qt-faststart sidxindex trasher )
IUSE="${IUSE} ${FFTOOLS[@]/#/fftools_}"

RDEPEND="
	alsa? ( >=media-libs/alsa-lib-1.0.27.2[${MULTILIB_USEDEP}] )
	amr? ( >=media-libs/opencore-amr-0.1.3-r1[${MULTILIB_USEDEP}] )
	bluray? ( >=media-libs/libbluray-0.3.0-r1[${MULTILIB_USEDEP}] )
	bs2b? ( >=media-libs/libbs2b-3.1.0-r1[${MULTILIB_USEDEP}] )
	bzip2? ( >=app-arch/bzip2-1.0.6-r4[${MULTILIB_USEDEP}] )
	cdio? ( >=dev-libs/libcdio-paranoia-0.90_p1-r1[${MULTILIB_USEDEP}] )
	celt? ( >=media-libs/celt-0.11.1-r1[${MULTILIB_USEDEP}] )
	chromaprint? ( >=media-libs/chromaprint-1.2-r1[${MULTILIB_USEDEP}] )
	ebur128? ( >=media-libs/libebur128-1.1.0[${MULTILIB_USEDEP}] )
	encode? (
		amrenc? ( >=media-libs/vo-amrwbenc-0.1.2-r1[${MULTILIB_USEDEP}] )
		kvazaar? ( media-libs/kvazaar[${MULTILIB_USEDEP}] )
		mp3? ( >=media-sound/lame-3.99.5-r1[${MULTILIB_USEDEP}] )
		nvenc? ( media-video/nvidia_video_sdk )
		openh264? ( >=media-libs/openh264-1.4.0-r1[${MULTILIB_USEDEP}] )
		snappy? ( >=app-arch/snappy-1.1.2-r1[${MULTILIB_USEDEP}] )
		theora? (
			>=media-libs/libtheora-1.1.1[encode,${MULTILIB_USEDEP}]
			>=media-libs/libogg-1.3.0[${MULTILIB_USEDEP}]
		)
		twolame? ( >=media-sound/twolame-0.3.13-r1[${MULTILIB_USEDEP}] )
		wavpack? ( >=media-sound/wavpack-4.60.1-r1[${MULTILIB_USEDEP}] )
		webp? ( >=media-libs/libwebp-0.3.0[${MULTILIB_USEDEP}] )
		x264? ( >=media-libs/x264-0.0.20130506:=[${MULTILIB_USEDEP}] )
		x265? ( >=media-libs/x265-1.6:=[${MULTILIB_USEDEP}] )
		xvid? ( >=media-libs/xvid-1.3.2-r1[${MULTILIB_USEDEP}] )
	)
	fdk? ( >=media-libs/fdk-aac-0.1.3:=[${MULTILIB_USEDEP}] )
	flite? ( >=app-accessibility/flite-1.4-r4[${MULTILIB_USEDEP}] )
	fontconfig? ( >=media-libs/fontconfig-2.10.92[${MULTILIB_USEDEP}] )
	frei0r? ( media-plugins/frei0r-plugins )
	fribidi? ( >=dev-libs/fribidi-0.19.6[${MULTILIB_USEDEP}] )
	gcrypt? ( >=dev-libs/libgcrypt-1.6:0=[${MULTILIB_USEDEP}] )
	gme? ( >=media-libs/game-music-emu-0.6.0[${MULTILIB_USEDEP}] )
	gmp? ( >=dev-libs/gmp-6:0=[${MULTILIB_USEDEP}] )
	gnutls? ( >=net-libs/gnutls-2.12.23-r6:=[${MULTILIB_USEDEP}] )
	gsm? ( >=media-sound/gsm-1.0.13-r1[${MULTILIB_USEDEP}] )
	iconv? ( >=virtual/libiconv-0-r1[${MULTILIB_USEDEP}] )
	iec61883? (
		>=media-libs/libiec61883-1.2.0-r1[${MULTILIB_USEDEP}]
		>=sys-libs/libraw1394-2.1.0-r1[${MULTILIB_USEDEP}]
		>=sys-libs/libavc1394-0.5.4-r1[${MULTILIB_USEDEP}]
	)
	ieee1394? (
		>=media-libs/libdc1394-2.2.1[${MULTILIB_USEDEP}]
		>=sys-libs/libraw1394-2.1.0-r1[${MULTILIB_USEDEP}]
	)
	jack? ( virtual/jack[${MULTILIB_USEDEP}] )
	jpeg2k? ( >=media-libs/openjpeg-2:2[${MULTILIB_USEDEP}] )
	libass? ( >=media-libs/libass-0.10.2[${MULTILIB_USEDEP}] )
	libcaca? ( >=media-libs/libcaca-0.99_beta18-r1[${MULTILIB_USEDEP}] )
	libilbc? ( >=media-libs/libilbc-2[${MULTILIB_USEDEP}] )
	libsoxr? ( >=media-libs/soxr-0.1.0[${MULTILIB_USEDEP}] )
	libv4l? ( >=media-libs/libv4l-0.9.5[${MULTILIB_USEDEP}] )
	lzma? ( >=app-arch/xz-utils-5.0.5-r1[${MULTILIB_USEDEP}] )
	mmal? ( media-libs/raspberrypi-userland )
	modplug? ( >=media-libs/libmodplug-0.8.8.4-r1[${MULTILIB_USEDEP}] )
	openal? ( >=media-libs/openal-1.15.1[${MULTILIB_USEDEP}] )
	opengl? ( >=virtual/opengl-7.0-r1[${MULTILIB_USEDEP}] )
	openssl? ( >=dev-libs/openssl-1.0.1h-r2:0[${MULTILIB_USEDEP}] )
	opus? ( >=media-libs/opus-1.0.2-r2[${MULTILIB_USEDEP}] )
	pulseaudio? ( >=media-sound/pulseaudio-2.1-r1[${MULTILIB_USEDEP}] )
	librtmp? ( >=media-video/rtmpdump-2.4_p20131018[${MULTILIB_USEDEP}] )
	rubberband? ( >=media-libs/rubberband-1.8.1-r1[${MULTILIB_USEDEP}] )
	samba? ( >=net-fs/samba-3.6.23-r1[${MULTILIB_USEDEP}] )
	schroedinger? ( >=media-libs/schroedinger-1.0.11-r1[${MULTILIB_USEDEP}] )
	sdl? ( media-libs/libsdl2[sound,video,${MULTILIB_USEDEP}] )
	speex? ( >=media-libs/speex-1.2_rc1-r1[${MULTILIB_USEDEP}] )
	ssh? ( >=net-libs/libssh-0.5.5[${MULTILIB_USEDEP}] )
	truetype? ( >=media-libs/freetype-2.5.0.1:2[${MULTILIB_USEDEP}] )
	vaapi? ( >=x11-libs/libva-1.2.1-r1[${MULTILIB_USEDEP}] )
	vdpau? ( >=x11-libs/libvdpau-0.7[${MULTILIB_USEDEP}] )
	vorbis? (
		>=media-libs/libvorbis-1.3.3-r1[${MULTILIB_USEDEP}]
		>=media-libs/libogg-1.3.0[${MULTILIB_USEDEP}]
	)
	vpx? ( >=media-libs/libvpx-1.4.0:=[${MULTILIB_USEDEP}] )
	X? (
		>=x11-libs/libX11-1.6.2[${MULTILIB_USEDEP}]
		>=x11-libs/libXext-1.3.2[${MULTILIB_USEDEP}]
		!xcb? ( >=x11-libs/libXfixes-5.0.1[${MULTILIB_USEDEP}] )
		>=x11-libs/libXv-1.0.10[${MULTILIB_USEDEP}]
	)
	xcb? ( >=x11-libs/libxcb-1.4[${MULTILIB_USEDEP}] )
	zimg? ( media-libs/zimg[${MULTILIB_USEDEP}] )
	zlib? ( >=sys-libs/zlib-1.2.8-r1[${MULTILIB_USEDEP}] )
	zvbi? ( >=media-libs/zvbi-0.2.35[${MULTILIB_USEDEP}] )
	!media-video/qt-faststart
	postproc? ( !media-libs/libpostproc )
"

DEPEND="${RDEPEND}
	>=sys-devel/make-3.81
	doc? ( sys-apps/texinfo )
	>=virtual/pkgconfig-0-r1[${MULTILIB_USEDEP}]
	ladspa? ( >=media-libs/ladspa-sdk-1.13-r2[${MULTILIB_USEDEP}] )
	cpu_flags_x86_mmx? ( >=dev-lang/yasm-1.2 )
	test? ( net-misc/wget sys-devel/bc )
	v4l? ( sys-kernel/linux-headers )
"

RDEPEND="${RDEPEND}
	abi_x86_32? ( !<=app-emulation/emul-linux-x86-medialibs-20140508-r3
		!app-emulation/emul-linux-x86-medialibs[-abi_x86_32(-)] )"

# Code requiring FFmpeg to be built under gpl license
GPL_REQUIRED_USE="
	postproc? ( gpl )
	frei0r? ( gpl )
	cdio? ( gpl )
	samba? ( gpl )
	encode? (
		x264? ( gpl )
		x265? ( gpl )
		xvid? ( gpl )
		X? ( !xcb? ( gpl ) )
	)
"
REQUIRED_USE="
	libv4l? ( v4l )
	fftools_cws2fws? ( zlib )
	test? ( encode )
	${GPL_REQUIRED_USE}
	${CPU_REQUIRED_USE}"
RESTRICT="
	gpl? ( openssl? ( bindist ) fdk? ( bindist ) )
"

S="${WORKDIR}/${P}"

PATCHES=( )

MULTILIB_WRAPPED_HEADERS=(
	/usr/include/${PN}/libavutil/avconfig.h
)

src_unpack() {
	mkdir -p "${S}"
	cd "${S}"
	unpack "${A}"
}

src_prepare() {
	if [[ "${PV%_p*}" != "${PV}" ]] ; then # Snapshot
		export revision=git-N-${FFMPEG_REVISION}
	fi
	default
}

multilib_src_configure() {
	local myconf=( ${EXTRA_FFMPEG_CONF} )

	local ffuse=( "${FFMPEG_FLAG_MAP[@]}" )
	use openssl && use gpl && myconf+=( --enable-nonfree )
	use samba && myconf+=( --enable-version3 )

	# Encoders
	if use encode ; then
		ffuse+=( "${FFMPEG_ENCODER_FLAG_MAP[@]}" )

		# Licensing.
		if use amrenc ; then
			myconf+=( --enable-version3 )
		fi
	else
		myconf+=( --disable-encoders )
	fi

	# Indevs
	use v4l || myconf+=( --disable-indev=v4l2 --disable-outdev=v4l2 )
	for i in alsa oss jack ; do
		use ${i} || myconf+=( --disable-indev=${i} )
	done
	use xcb || ffuse+=( X:x11grab )

	# Outdevs
	for i in alsa oss sdl ; do
		use ${i} || myconf+=( --disable-outdev=${i} )
	done

	# Decoders
	use amr && myconf+=( --enable-version3 )
	use gmp && myconf+=( --enable-version3 )
	use fdk && use gpl && myconf+=( --enable-nonfree )

	for i in "${ffuse[@]#+}" ; do
		myconf+=( $(use_enable ${i%:*} ${i#*:}) )
	done

	# (temporarily) disable non-multilib deps
	if ! multilib_is_native_abi; then
		for i in frei0r ; do
			myconf+=( --disable-${i} )
		done
	fi

	# CPU features
	for i in ${CPU_FEATURES_MAP} ; do
		if [ "$(tc-arch)" = "${i%:*}" ] ; then
			local var="${i#*:}_CPU_FEATURES[@]"
			for j in ${!var} ; do
				use ${j%:*} || myconf+=( --disable-${j#*:} )
			done
		fi
	done

	if use pic ; then
		myconf+=( --enable-pic )
		# disable asm code if PIC is required
		# as the provided asm decidedly is not PIC for x86.
		[[ ${ABI} == x86 ]] && myconf+=( --disable-asm )
	fi
	[[ ${ABI} == x32 ]] && myconf+=( --disable-asm ) #427004

	# Try to get cpu type based on CFLAGS.
	# Bug #172723
	# We need to do this so that features of that CPU will be better used
	# If they contain an unknown CPU it will not hurt since ffmpeg's configure
	# will just ignore it.
	for i in $(get-flag mcpu) $(get-flag march) ; do
		[[ ${i} = native ]] && i="host" # bug #273421
		myconf+=( --cpu=${i} )
		break
	done

	# LTO support, bug #566282
	is-flagq "-flto*" && myconf+=( "--enable-lto" )

	# Mandatory configuration
	myconf=(
		--enable-avfilter
		--enable-avresample
		--disable-stripping
		"${myconf[@]}"
	)

	# cross compile support
	if tc-is-cross-compiler ; then
		myconf+=( --enable-cross-compile --arch=$(tc-arch-kernel) --cross-prefix=${CHOST}- )
		case ${CHOST} in
			*freebsd*)
				myconf+=( --target-os=freebsd )
				;;
			*mingw32*)
				myconf+=( --target-os=mingw32 )
				;;
			*linux*)
				myconf+=( --target-os=linux )
				;;
		esac
	fi

	# doc
	myconf+=(
		$(multilib_native_use_enable doc)
		$(multilib_native_use_enable doc htmlpages)
		$(multilib_native_enable manpages)
	)

	set -- "${S}/configure" \
		--prefix="${EPREFIX}/usr" \
		--bindir="${EPREFIX}/usr/$(get_libdir)/${PN}" \
		--datadir="${EPREFIX}/share/${PN}" \
		--docdir="${EPREFIX}/share/doc/${PN}" \
		--libdir="${EPREFIX}/usr/$(get_libdir)/${PN}" \
		--shlibdir="${EPREFIX}/usr/$(get_libdir)/${PN}" \
		--incdir="${PREFIX}/usr/include/${PN}" \
		--docdir="${EPREFIX}/usr/share/doc/${PN}/html" \
		--mandir="${EPREFIX}/usr/share/man/${PF}/man" \
		--enable-shared \
		--cc="$(tc-getCC)" \
		--cxx="$(tc-getCXX)" \
		--ar="$(tc-getAR)" \
		--optflags="${CFLAGS}" \
		$(use_enable static-libs static) \
		"${myconf[@]}"
	echo "${@}"
	"${@}" || die
}

multilib_src_compile() {
	emake V=1

	if multilib_is_native_abi; then
		for i in "${FFTOOLS[@]}" ; do
			if use fftools_${i} ; then
				emake V=1 tools/${i}
			fi
		done
	fi
}

multilib_src_install() {
	emake V=1 DESTDIR="${D}" install install-doc

	into "${EPREFIX}/usr/$(get_libdir)/${PN}"
	if multilib_is_native_abi; then
		for i in "${FFTOOLS[@]}" ; do
			if use fftools_${i} ; then
				dobin tools/${i}
			fi
		done
	fi

	exeinto "${EPREFIX}/usr/$(get_libdir)/${PN}"
	doexe "${FILESDIR}/${PN}"

	into "${EPREFIX}/usr/bin"
	dosym "${EPREFIX}/usr/$(get_libdir)/${PN}/${PN}" "${EPREFIX}/usr/bin/${PN}"
}

multilib_src_install_all() {
	dodoc Changelog README.md CREDITS doc/*.txt doc/APIchanges
	[ -f "RELEASE_NOTES" ] && dodoc "RELEASE_NOTES"
}

multilib_src_test() {
	LD_LIBRARY_PATH="${BUILD_DIR}/libpostproc:${BUILD_DIR}/libswscale:${BUILD_DIR}/libswresample:${BUILD_DIR}/libavcodec:${BUILD_DIR}/libavdevice:${BUILD_DIR}/libavfilter:${BUILD_DIR}/libavformat:${BUILD_DIR}/libavutil:${BUILD_DIR}/libavresample" \
		emake V=1 fate
}
