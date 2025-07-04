#!/usr/bin/env python3
# coding: latin-1
from __future__ import print_function, unicode_literals

import os, sys, time, bz2, shutil, threading, tarfile, hashlib, platform, tempfile, traceback

"""
to edit this file, use HxD or "vim -b"
  (there is compressed stuff at the end)

run me with python 2.6, 2.7, or 3.3+ to unpack and run r0c

there's zero binaries! just plaintext python scripts all the way down
  so you can easily unpack the archive and inspect it for shady stuff

the archive data is attached after the b"\n# eof\n" archive marker,
  b"?0" decodes to b"\x00"
  b"?n" decodes to b"\n"
  b"?r" decodes to b"\r"
  b"??" decodes to b"?"
"""


# set by make-sfx.sh
VER = "1.6.1"
SIZE = 40441
CKSUM = "d31aa4a22bde58c56f2b81ae"
STAMP = 1714259696

NAME = "r0c"
PY2 = sys.version_info < (3,)
WINDOWS = sys.platform in ["win32", "msys"]
IRONPY = "ironpy" in platform.python_implementation().lower()

sys.dont_write_bytecode = True
me = os.path.abspath(os.path.realpath(__file__))


def eprint(*a, **ka):
	ka["file"] = sys.stderr
	print(*a, **ka)


def msg(*a, **ka):
	if a:
		a = ["[SFX]", a[0]] + list(a[1:])

	eprint(*a, **ka)


def u8(gen):
	try:
		for s in gen:
			yield s.decode("utf-8", "ignore")
	except:
		yield s
		for s in gen:
			yield s


def yieldfile(fn):
	bs = 64 * 1024
	with open(fn, "rb", bs) as f:
		for block in iter(lambda: f.read(bs), b""):
			yield block


def hashfile(fn):
	h = hashlib.sha1()
	for block in yieldfile(fn):
		h.update(block)

	return h.hexdigest()[:24]


def unpack():
	"""unpacks the tar yielded by `data`"""
	name = "pe-" + NAME
	try:
		name += "." + str(os.geteuid())
	except:
		pass

	tag = "v" + str(STAMP)
	top = tempfile.gettempdir()
	opj = os.path.join
	ofe = os.path.exists
	final = opj(top, name)
	san = opj(final, "site-packages/r0c/ivt100.py")
	for suf in range(0, 9001):
		withpid = "%s.%s.%s" % (name, os.getpid(), suf)
		mine = opj(top, withpid)
		if not ofe(mine):
			break

	tar = opj(mine, "tar")

	try:
		if tag in os.listdir(final) and ofe(san):
			msg("found early")
			return final
	except:
		pass

	sz = 0
	os.mkdir(mine)
	with open(tar, "wb") as f:
		for buf in get_payload():
			sz += len(buf)
			f.write(buf)

	ck = hashfile(tar)
	if ck != CKSUM:
		t = "\n\nexpected %s (%s byte)\nobtained %s (%s byte)\nsfx corrupt"
		raise Exception(t % (CKSUM, SIZE, ck, sz))

	tm = "r:bz2"
	if IRONPY:
		tm = "r"
		t2 = tar + tm
		with bz2.BZ2File(tar, "rb") as fi:
			with open(t2, "wb") as fo:
				shutil.copyfileobj(fi, fo)
		shutil.move(t2, tar)

	tf = tarfile.open(tar, tm)
	# this is safe against traversal
	try:
		tf.extractall(mine, filter="tar")
	except TypeError:
		tf.extractall(mine)
	tf.close()
	os.remove(tar)

	with open(opj(mine, tag), "wb") as f:
		f.write(b"h\n")

	try:
		if tag in os.listdir(final) and ofe(san):
			msg("found late")
			return final
	except:
		pass

	try:
		if os.path.islink(final):
			os.remove(final)
		else:
			shutil.rmtree(final)
	except:
		pass

	for fn in u8(os.listdir(top)):
		if fn.startswith(name) and fn != withpid:
			try:
				old = opj(top, fn)
				if time.time() - os.path.getmtime(old) > 86400:
					shutil.rmtree(old)
			except:
				pass

	try:
		os.symlink(mine, final)
	except:
		try:
			os.rename(mine, final)
			return final
		except:
			msg("reloc fail,", mine)

	return mine


def get_payload():
	"""yields the binary data attached to script"""
	with open(me, "rb") as f:
		buf = f.read().rstrip(b"\r\n")

	ptn = b"\n# eof\n#"
	a = buf.find(ptn)
	if a < 0:
		raise Exception("could not find archive marker")

	esc = {b"??": b"?", b"?r": b"\r", b"?n": b"\n", b"?0": b"\x00"}
	buf = buf[a + len(ptn) :].replace(b"\n#", b"")
	p = 0
	while buf:
		a = buf.find(b"?", p)
		if a < 0:
			yield buf[p:]
			break
		elif a == p:
			yield esc[buf[p : p + 2]]
			p += 2
		else:
			yield buf[p:a]
			p = a


def utime(top):
	# avoid cleaners
	files = [os.path.join(dp, p) for dp, dd, df in os.walk(top) for p in dd + df]
	while True:
		t = int(time.time())
		for f in [top] + files:
			os.utime(f, (t, t))

		time.sleep(78123)


def confirm(rv):
	msg()
	msg("retcode", rv if rv else traceback.format_exc())
	if WINDOWS:
		msg("*** hit enter to exit ***")
		try:
			raw_input() if PY2 else input()
		except:
			pass

	sys.exit(rv or 1)


def run(tmp):
	msg("sfxdir:", tmp)
	msg()

	t = threading.Thread(target=utime, args=(tmp,))
	t.daemon = True
	t.start()

	sys.path.insert(0, os.path.join(tmp, "site-packages"))
	from r0c.__main__ import main as p

	p()


def main():
	sysver = str(sys.version).replace("\n", "\n" + " " * 18)
	pktime = time.strftime("%Y-%m-%d, %H:%M:%S", time.gmtime(STAMP))
	msg()
	msg("   this is: r0c", VER)
	msg(" packed at:", pktime, "UTC,", STAMP)
	msg("archive is:", me)
	msg("python bin:", sys.executable)
	msg("python ver:", platform.python_implementation(), sysver)
	msg()

	arg = ""
	try:
		arg = sys.argv[1]
	except:
		pass

	tmp = os.path.realpath(unpack())

	try:
		run(tmp)
	except SystemExit as ex:
		c = ex.code
		if c not in [0, -15]:
			confirm(ex.code)
	except KeyboardInterrupt:
		pass
	except:
		confirm(0)


if __name__ == "__main__":
	main()


# eof
#BZh21AY&SYè÷t÷?0éTÿÿÿú‘ ÿÿÿÿÿÿÿÿÿÿÿ\Ôÿ]€€F?0?0 P?0…`ÂÞûæqãáè¥j%|·fÑ÷ßuœö¨?0{Õä¥›Y¨Õ÷Ñâ÷–×zÕ{Ÿo}÷5÷3Ýóžò!¶^6›¶åTí®–ob÷¾ºõíèÜ–@öUïv[]§žÏ¡©†ClHÖ{}?0¤CÍzÉÞ;g=¬»hqFi^o7›½ÖÝ<›î8ûÎp÷Ûº–—;¯Ÿ7zoO»Ü}_5ï¯z¼uºÞ¦L5eÜh8*…*ëõ»·/¾ßï}¸;{°BHµÙ›Ú÷¸®“e±ªs-«·ßfíîÌ_c{;»¾“¶,âûí:™u»j¼w¼0Á*(RI®Þå@ÓM+m›kuÇ©}:}j÷§5—K`{ÙZ¢TÕë-5›Ï¾¾„Ï|ÓQj£‡z{ï¼ûk^ûÞ’”¯aÜÊïZ÷¸«Þ¼Ï=ÎwW¹/zÅ½A²§KË9Aé"æ»ß}·˜ª÷ØÛºåÝÎvíöxò{qnkº}|ø±¾ÁZ¶û[{¦ÞxaY•MdÅ“-µo¶ö¯*íªúáéÞo=ÝÛ5Y„¼ð?0]<Ã°ï°ß|îm÷º×¶Û¸‡=·dÆhl´{¹÷À<º‡×Óªí×Ö¥¹8§{ž¾mãÛ>riÐ?0?0 	ˆÐÐÓÀhdÈÒžò=Hòj20††ƒ! Ðh #@hšLÑOE=©èBmfF¡§©´¦Ô4ÐÓCÔ?0?0?0?0)ˆˆBÚI½AOF”ö©êl¦ê?rQ õ¨?0?0zPÐê?04Ð?0?04šHˆA?0‚dÈÈh@Ñ‘#ò'ª~J=CÔ4ô†™¤ÑˆÐh4d?0?0?0?0D‘h4a24Li1jy5Oji¦J~š“ôÔòQújž£õOP?0h?0?0õˆ‚	 ?0M4Mj`§©é†L£?rM¢y4¦ÊyCÔ?r?0€?0?05ÞvRW÷èþ»¥C™¶ºÄ$——??4¬.yˆHV¢p:ùs>„³á§Â§Ï.$þl³BmæÙIÌŒÙACµ¢u¡;²¹¾¼bwg<wqx:cÐdN¬ŠŠ¤‹ À"+ðZ! ÖºRX?n¨?rˆ*??[>+¹E2 ¢Ÿà ”¨c%QAE0Ýìý¿¯óþïßÝ=ïÛ3ù›ðýÙ[ÞIgáVþàïð2ÓGô©SÂÅ-_ãgîYË(##Â†ËØ!PÖ«Öc77òú¹WÚ:¤Ž’6 @ &TE”ým­•Íý"Sdýóõfß¼_%I??Éá´êtM?n ¯Á\ŠÌ‰ýõÕA">Rä-0þââÆRÞ4Ò`åÜµ%¾^çd´i•Â«Ad$È£¯}ë‡„«Ùñ??hï^îs>£æ3!-±¤ü0žS!vþ¢!äÚ3› $zj|wÔ)©êH—¹V.¾+÷©ß+T>±‘4é$)áNß&A$Œ®2Í·¾˜ Úëåž»9›üKžyÞ¡ÜÄ~*tÂŠÖ¯n4îmqê”V.Þøþ¹Ÿ‹‡rC:ÉÓbæùêÌ½a,á?rQ¨å!ˆ5<J5’´÷éZœ ÖçkoÇ¿Y“1ŽÿgÖ¹žm¯¨ûMòî\#N¶d‰ÏpVz,6ºÖ	Ë>7&ÊVJû ñžV*‹‡Pa#=³fúx¬“²1Y‹éBéÚéäå8…9º¤‚"‡½×³ÔÃ­¯ÏNŠ†|VmÕÌ7lÆãÑ¾ö†´×“/Í†*~Vy­m2×Áº1]œÙ63_‚E‹f£4b/p×I	SêÄÜ)‘“8VýÙ™Ý?nHâIlj½eÃjŸÍ®÷¤%AYCm”q2éâÃCõ½í7–Ü[ÊlÛaÞpg‡*èD™^m"·¬ìôêGycÌÊj§™Ž?nŠxœÝ]êŠë.ÅÃAj.‡±‰…§BÔ Ò0,ùõõµ½2˜Ùm’›ú³µ•‹ÑxFúTlŸU×³7¯-K„ã-õw‹ßð8¼š‡ûN®F+{%gH~öƒ+%fð}Ÿ&£*	ŸŽ†bÓŠ?r“«5eé’þ@pùW[÷ÿJñ£7ŸëuyeÝ±–8mŒ“?0Ñ¤¼Ú%Œ{`Ž¶J=Ú¸NŒÞÂ©Ù¦Z øì©OKG'ÜîÍÏ›ƒó”>GôÍß»*FÐŒr4Ÿ–YÛ6‹¥ÒŠzñhO¨÷Dš„+raánQË„º×‰gRF„XØ:Û¾LïÕ¬|lÎ?rflÐÚÖyø=³ƒšsßx[evY¡ôlv6Eœïj±ªw‚24’i¨ùÓ«ótõºÈìwöŽ—¢÷óçÛ{H¤*ç£à‚÷TV¹h¨Ô*ö“;³|n?0Û¡‡ævþ*{>]Ld<2}€R»õ½I§§Ew$]‹öZÄ…ïW4sð„a‘àS,ÉB‘‚“r¤š§B9kf»”*9O–Í=ü˜dóa^ªÁ·l¡AØ†>|ó£Œn¢¢wV^µŸëQ'è•ì’Èa>xhmÒ°emý¨Äa…+»??ØÝªTw—JšÔ)ˆD#·(É”k*™áS{§éXqHÞkb¡Ÿ\rxå?r’òÛs–0,¶‡o¶~æIfl×¯ÿL$ý~X“ã†ûYÔÜ=ØÁzÖ~Òºš¿n5/P…¸%G…LçÍ4‚HÕêÀP…s˜5FÏÊÿÛú¿²jœw°ì{’È•Žç±åå2|é@KÊWºª;XÍ“(h)2"3ø@±2ÕÓoÛÝÑ$yÔ" #þ*óŸƒGù-îd ˆðñDx¹GªYéšÿÎ~Kÿ6*²e‘REA2‰PY’Ö¤jû?nÓyt5ß¸¸i‘³iBc¬‚gà??à²©°‚‚5ôÕÐ ÖòOFØÃì°„üwŸSþŸ×²¯aW×*P~A9h5Äþ/ù*$m0S²TQù=ÚP\v"#&Ò©ÞP?n|(H„ùíúü|—‹oh|› $eÌ¼›)ÂŽHQ!Ä¥,»è×Ùí)õ0:‹ü÷_{£ë;YbsJ‰í?0õ×ñ=ª£4ˆ†6¬ÅõÓoÌ¯ƒËtêÒ (¨¨1¢?n(ÅXF?nˆ)ÜRQXÈm€VÈV(¨ (±Gèn™ø¸Ï[X±AY² »ç1" ˆ"ÆB*?0È1Š1R1EŒŠ(FsÆÈd4ˆ$X°F1Š±ÒUcUV"¢¢ÀdAU‹U‰ÀæUH*+Œd‘`ª¨ŒUAR(¢¢ÄEˆÈ’"DR(ÅHŠ$X$cDQEDTcŠŒ‚¢c‘DU"¢ŠªŒHÅH Œ"šmýohI¿­.EóÞdý/]4ëóÝqaÙ•EF#?nÃÖr:ÎÛ¤É"Š::ñ3'…6½¹2TD,lœ=³]©,c¬ADƒ˜Q„k£¢½°lpâ£G8—ÝEáì‡~ßF˜õþ×‚??Óšd%ÏßíõþØ×¢ZB¼•¶/:Ã·÷CZQ¿)¡á¯ù<CºEëðè–êËƒ;íFø€KZòg•íâB·Üw)!2ª5VTUYë´AA¢p%Ø¼—”ÎÉ“ßoî<QžÒ×ÊÄÑ®tf*bž0ßˆWàþ.TÙÅòµSÊÉiA±ú±6vjrn}w X JÐÿ‹þm½§¹\Û Äköà!^?rƒù~¯uêž…?r#€×§0˜nƒãHAû†í¿Íü¯û~£åïömç|¯øÑ^³ÿjÅüÐùûâ{UrVÖßêvüõ°mšsäØt	y•Ÿ7äWr.E,Í,nN?n=£Ço­×Ü]~Ã­P°ìØØ˜ÈxÈïõ??£n;­›FT¾.jüåŒd‚~€äl¶¿)ƒ2‚hAå—ëhq¡¾û}÷Eùe?rØéåQÞÇ§:5’ð`S¾Q€f[¾æér?n;“|Y÷ñöI»mƒkWäH6{Fé·¢—Hl´¹zNÀÎBVÃq¥¶óöõu>È',›»ÛòV@|Ïzó¼²·†®!Â‚W†çjÍOFã1hÐûÑè.??DBé`ƒÔ“{QJêé¦_¶D$®¢€4­ß%‡¬˜‚cw ÃiÚ¶ø…Â‡Aî×·iBK:ÝOä«šñ«Jïôü?r?0¿r¹Ô¸	‘"x¡Ð	"éÑM (ðsA–¯÷üÜ8å9öç¥Ä§bJŽ²gA[{7Ið»W+NŸ´Ë”€”ÄGÐ_g^å¡ùRŒ‰0‘" Pi´Ûdü~zo7qµÛúþ÷1-'ž¬HY=ÅCØE´øëküVCGÑöì¢8íðZmÀ|`|ó®ÈÐ=Ý[Mú>èôî™A©óÞO^¥|fÈæYŒJ¼ c©ºF‹gH¡P.»ÏuŠo0¤úWhŒM€u'5f??üf‹LØ:Á«Ydö|ŸÆßö~eå×??Š`¡ÂÅÈ£ ;ß8Æª#Q¨¦$°I#¹GjŒ­„@ÀírÜ::Á?r¬ýÌú6™¤þVn¯RÆDÀó8«¾oéÐû??²qœ¸ßDÁàxÅ!57Šu÷”Æu(‹o‰üÕÆ_+ŠM¥á±ÇÝZEtë2C?r?rÍë6:¥)»&·DÅ†âZÛ?nÉnH5B¦¤0ºöU­|íìÜI[D„I#z¬yÁ»•¦í”Zi2ˆ*râº¼°Y­ì•YžÖ·whLMŽô]»ÂÒºeu¢³Ü–µ+ZËKaf&óJŠ3uY0UÒQm¸‡áe`p”A—S8»zBa!T?nq6µ?0ÙQÔ_ÁF¢ÐœT‘ÛøXô(Œ§³·ÂèûQ	Œ)Rì<Îs_E.„>áNL’Gkˆn¼£¿Ç“ôêGë%·-'ËpwŒ[ ÷²kÍ%EºÖGk¤Š È¢oãPÜËœ¿Õ}Ó¨¸TiXJÊè‰ße!C'ø=¦l›Åæ×Nï;î¹Årpäv*Ýã‘ð”|~ŸãÞd<?rU0 0Ð?0*À`ìøzªºg’>Ûª²úO@ï‰øfÏJÞÃ×š­¤Ž‰"¡jXo??(Fš¦&ˆ÷1f!š§I8ˆ¨âÁ‘<nìdl¤4=’/Ê	T*`Ú…b•IAØ*û«ógïê6a‘S;±¸…?nŠl!‘D²W?ndé3Î’ôÇiº"Tš8`¥TˆÑ¨ø·Hôg¦íC5C¥Q	P|…©e“F—W
#"†¯û:>Ö»?nÕPVÓlwË>—ce•È³ÈŒ4¢&Cç‘\à©g—Ü–`m‘Q bÚáñ8†Ý¦68õ}sAL´Ü|r€…†2È º¸#ß»œqq¿¢oÒ7Ñ8ž=àR,®>??U‘ý&~Šu/\/|ú÷‰û>¹Õ_B7GÃèáË#rµ°-²Æ—Š7@k±[YF’è8ã­(FL}Ë,™àPª$Õæñx¸??%-Ÿ?nñWá¾°¬Át|Ö}w(ü!–ƒ×fgL	¨G:£1´¢—¿7¢Š&ç7ÉeàßQ??låw»•<8n|šX@“mdæ²…êQÃšbGjlOºŒu)ŸhÑÊETX*¬T‹y†1dŠ¥Üöñ£°´ñK]}F™—ÏSx«#!¢Ø„1¤ßÊV®ò§<z}´?ro	›¾¢10Þí| cn­èÕ¥?rÚøùbzöËº^i@¤hˆRyªÞÉ>?nÇ6Z”åÂÕÕyBQµJª´Í_*=q´@2‚?0‘ØÃ½àw;ËûWçÅ¥ù*qD$1I*8õôq>ŸœÑ}|?0$6!¶Î—èË^Í}”µMÔû«`J·ëo³Ó•õ^ól!AØÃXÒlÆ„Ž½oïjlqHf•zq‡Ø½›cUß‡V¨4]¤ÅŸß¯âó¾^Yæi†£:F»^\§‚?r³;;“â¥úY¦}Þû%ò§r“‡¢7F"øØÓ¶F4æ‰RBEDy?nb•(“–”<8q>í Š‹«®»’­ý#4tá8 ’ VÀâÆ b¨.SL*5'=À›­¸RäU>rÍìÕ†ã†žÝÝšf´Ü2?rfR?rŒzXfÏ~|ú¤­Sèâw¼¯ÏFvæ±ËœçéÊô…|”NÇ¾™Ó—a+QJ^iyé›Êƒ°ý£ïèå>EVþ4ŠI'µ@-$S’7k(BÐÊ"rE:â·Š‰êõÐœÐ| ,D1€c*…˜v´öÐ‚RZ3Á·7Džš~{ýô·¨(x3‡f…@¢G%s{,öŽ=I’O‹Ÿ3%¶‘îÖ8C8£æ²k:ÕÐŒ9†8ÂEp²pÑŒê4¸iYQèâ‹{™ÆÄHB*wñÄúf>Ù2åñÄÜ¨3*ÃZqÐ›¶Òã_¢&P‹aË¤Þ"µ\m÷U0pÃËfäuÌHÛk8î¾«®V*<ÁŽ€§+zë¾ÆÙdÓçÚ”[™Û]=jÚŒ]´:LÐ&¾Ëî®ÅîLÆ˜°«<ã¶çZÎÓÆ2ÖøžXäSF%ØŒïI=îŠ¡ úÌú™fS†]›¿NÕreà¯¿&??2ŽÖxèF&ºz²?rO,ßå<ï6¿È‹–ûö¶Š3±J	ð#¯z’é?n ¹%‹ fN×ò¥;Wë‚I&·°ÇÕàµ•”ÉATU?nR£_F	>èÁLXJ‚Ê¢j…TØÖ‘QïÊ6ª?n³%Œ7,RÄFt‘QŠŽ:?rÇè½èaA•XÈDû‚…è”Ýð]ˆ2[¦vnV±·Y”QŠNdJÑVêZSÒxGø#ñvÀ‰¦‡óöZf&½úÄ´NÌ¶Ÿàz’~'|ë;I“dÑÓú:”??†[Ÿ%ï3†…|4]Ðn.'Uu?0y¢ý’uó×^VØÉg–}nBŽìíêöó_w„÷„ÑR*€¾ÜªšUbèª _a˜n”µ°¢¶Ø°=IP6—ƒy–¥<¾’ï«×²x˜þîûwŽx³É•-ìdS¡Ð“éò%[sd6\Pºþwˆ°à,[CwY?rØ	Ö9L¡×°_?nsµ…óðÜç5ÊXT“yfúÀÕD#ÇÑ®þpÍ"°jó(ÍÇôÆž(ƒfÙáîá*ÚÉ¶jÊ¶:V?r>¥~áãgyÿlÑ_Ž¼j’ý×÷®ªmbje“%4e¢ýÚú¯v—YPÕö`ÝVö˜¹!ÍC?n0‘@s?0<©» ñ¤áà…*C4ÄD“•h.âãœ5H•Ç–m~Ø`d)˜ò‰°ž­ç^k@@£¶µLË‚SdŽÌ©On£·-õãŽ_žÄ¨9?rC?rÆ[6˜ØµÅRÄLÍïÛ›?n£[6ÁÐ>Êù€dVÛU{ŠñÚØ…Äø"À‡ç–ZI+Îãr‡˜Øþ Eb¨c)Ä6}¹ë><ç\ñÀÅS'&U±%™…`½£Üð¥•Ç·>8ë8mí=»O‚1,‚›.§ÉDš‹mB)\ÅTAZÃ<± €3a#@W%ÄStúEeÜ¡N<ëíºm›®–4!7nœ+±m%EÈbÀàè÷‘‘Å(kgõe/¹~§Ó$ÈÌ?n2)™ÖrêÙŠÕX4H’µ¨éW¢åuôUæ¢¸âÕŠ‚xí8k«[´q‘vš-aƒ}™Ìl¯¢‹gÇ(eJ²:ÙÍ]’@OºQ)¢ùÙ[èl&Ï7Ó°N:€!§“w¼¤cÃ†+LwŽ­*yçö3ÐxUE§ÆŽ¤ÊUFíˆ7ú«ç’$ã[Šrê[æ?nq›_+ª"½/ŒÒðf-Ð‹KÕ³!P ”	3l	=¦Rf{³ßç‚!“)%À¦PL;¨º‰! °yGçó|,)ð÷``=nYŠ<‘!×Ûšß0£Št??O½??¸Ê]í‘FgYx	R`ÖÔˆ±»ÚÕß$xuÈHImjÚ	Vt>9Ò¼¡tzÄ}â–Tì)êè¨¼Óiöìá‡n~N1”;éÍQôè_›ÆæÚ8åo„tkûøb?0˜÷½ui~w¹í­&Tv7«ò"!sYöáYLQixBÝßN™âôÐ`bAo<Yç4ÂªV3¡ØÁ÷a-ý¾Ø–«ÀÄfPs@-US¦KÑÖ›Š[Î$?rò÷cNƒ;\QMã°Ækzõˆ9‚-ÛÀêžÏçueƒ-JßW6¶FÆ‰jwv‘l'¡Xòa”<Þ¹a¾Gðº½Ëp»Ø(xÃ?0ÞïÕû=óÐÏ¢Íå??5Û³ÎöÿÖð??Ó$„É£þOÊoõW¦ÏgÔ4qûYùýy=o ñD{Žãêí1;ŒäéZ]áCf#02ôoþ¾„?nìþÓF‘öw)‰ªË7Xþ>ßF_<°ÿäÏ??¶í¥«Þ÷#XÌy&é²'½??X#Ë¿š‚Êtwè`¾Xà±è*®cÕ T<\~ÃøòÂ †î“ê\ÝTþÜB Êÿhÿne±WéÕU'ì„üç!è;éè“d¥xOàÆµ?? þ[Wî¾öû£»wA¸¡Gûƒ”ÀQŠ:rš*|0ËÌ,Ø“RX/¦ñbW†*—i+4rìQŒ,éjfP†ÚdcÐ~àíá÷‘Å¡I5¡„}q<ß-HÑòÐü¥šWÏù`ß©ˆÏÆcm&®xjÃû"¶p—ÚÚ`}Ý,! ¡¢_0oÂäpa—gàXÎÉµ5[ö*°ŸŒIÜ‹yø-ÕYÒÒøÌI'øåh®7¡Ì9ùzØª¨–ŒC÷ÎüÕ?rkÝuòXn#­áÀ°jà®wDhA?n/oÖEDFlÖ¶¥…Ì¸±‚ m*´6ÃËÛ>Ÿ¤ºÒlÅstúýgà‚€øæ©Çùÿ*•ïØéù|ì°ÈGš>‡7Á±‚ÓÓ&P®háæ¹†–†4xÖ¶Rœýç?0ÈàÆEÂ\Ñº6Õòáï9ÑIñ*vËÊÏòe©Ò¹ò~§z¤z8Çq¨øíŽ»rë<°`©ò°…Œ¯¼Ã ˆ²E&ôåmÖµ??®Š´þ¨™W‡÷ûÜRŠ³	±3›Açóm€g“…Ìza!ÐqF¶Œ:q õõÞcžÒ¢¸tëblOêSÛ'®y—³¸Eëö°õ$Ò¤RTl?n‹÷²ØÎº…žÉ‹D- C±Ž†ØÑðq¸eýÛö??Ñøûve¿_×…óº!’U²¡ÎwÅÁ<??uÌô}ïf»…üfW¾=2MÍJÄÂÇë¼}}Ï]t*E(žY[ÜÇpÏõÀÑ£FÎ³Ýºøä 	iAS=”‘×* WÓ‹tz¼hÏÑŸÌ¢)€¡(Bb¢6õ±žúÕ3ˆ¼Ó{°ÙîO¬VÓ3ÈÍHZBÆT1fWr™†fi½"Euã#\ˆ²:0¥ûºàçG_½io“ë{s÷Œ‘bå?rÂj×ú¹ßÞkùñªŽx5Kðïwx¤Ë$¼îfƒQKÆCÜ£Õfh³yL³{8±gWñB±0y	aè3÷*]½Z?rYä´P#ì?rÝÍû¿§3Àt?nBohDìˆª˜¸Â??ŒQ³õ^Æß‹ÿ	)H??©Ÿ=¸+eQÜlB”ö•ß"VŠKýÕÓ}ßv›X£æÏÈßOÁíÿQ>Å.ùY)³æí½,ø|ÌY½=1;¹Ù°Ç?0D€w:ô¿åÒŸÄ>Ÿ ï\žWÉ“¨?r«óyÀå)œ=þÂÖ_àß’-2Á3Ì8DšC“ÔƒÜÑØÕ"|ƒsJ¢”$IçPÂ)˜€ÎƒøéÏ}ô6Õžp^sçVáE&(/»Ÿ·oé÷ÀæwÔxBÓ]Á4 äN¢Þœ"(?0ðÀXÖû²pîmÜË:}|>÷_v’Ïsgœz?n~2ŠP)¢VdV¼}ßd-'OÇÕâõ/ˆÒ÷µhl„}M+|§ìMÚ9°ÁÎòÍ©™Iü»lÆšiAvµS”ƒy°Ã’Çié,íHÉÝ3Ë²¾tË??aªaaQ¦þ¿§è·oc]‘“*%µš`Cgeä«Ù²¡éÇÙÕÃÈ·i“e‹ãˆe”(ký’ùðwàè¡åÕöûuEL¦ÎTÅ”ùäæŠþ‚‰œ¾\rZÛºÿ'íÝòôk¹x=Ê³ËIõ¾_§Þ(çž~(Ù6ÌÍÊçÛ¿—^;‰Çßä’VÓ‰œr™8#4ÂAm\<kšf›	ÖÙWš´Y?n¯hŽÿ8é²„ùúÒþøöüwïRTfØ‹s[‰SLÙâÐU¯±Åûf'd¸YuTýëQ×;SûŸN¸<šæ5Òqíò»aøÃ*m€µ¸È D0¶ß#Ù–f”MSfP¿Ïùü½Y#æ$‚a¦)Í÷B˜/U4(ÇMWÝ-	ªºŸZÝTª$Níl}TÖr£X()ƒfŒÁà/›¸&NWâ3c¢Î„é¡E]F6o»ìûÛðæò’£@Û÷mƒŒ, ¦ò¯VÕm!¤”dÅeJ1+Š‚±EUE‹*$hQbf†Â²L$?n$j¡
#?0uÙ¦O©¿îÿ—÷g÷pþßíÿ	tÕ´Ý~fzúN??wù®uövxÁ4 ØØ9¯ãä}~…gÆæK„ Zá0i-úf´i9“YB#)’®c™nLÊÃñÚÆkR…îÔÅ+“?níþS#²©B$•\s0çÊO‚T¦£ù7y^¿—®¥×éü²®æŽ¯MFfÈ;ö†4­cÂ¶Á5l g ’F€ôás	‘0Ì”Ã31!XÐÂ¬*=ì{ž­f6¾Æn—å‰ƒÖ³~ É¡(ÒH ƒ‘ZIUÞ]«…&3Õ”DK¡ÆB87PDÁ—Ñ­îÒxæ`#õ7"éë’ê’iCšáìÖ?rhûL2¦$f2(* ®*ƒ!‘Á‚”B\–•ä)ˆ‰> |h-/˜ÈÚ'7ìÆê÷<½3³Gððâ°˜`Hz,iÕùé}*šô"JN»PT´T&Ë^ü°>A­ªY|Û0ÊI¯>	vp½Ãm¤}Õ5Ùü2¼xe5T}s8Fté›‡sYF÷LšfìeÍÞÛ×¾á­µ[½JV  I 32¹Í+7ÅË?r‚LáFJY'U ¹ç&{àT2/m:Ë´2?0úÂeEå–7(_)fž?n	gwø<k4õ®âñÜeuÝ(·n¬§lIaUtKwÔ~7¢ÛÇÒ©¤5›<KQóÁ¹í‘iM´¸†A‰ˆ3ox5®£YÒ!Öð~øó¹E–ãvî·Kóuké‘~'`]ñ]Ð:^äÿœŒ¶Ò\@ù£ºgï8WÍQàF+žÙ­ð*Š‚<ÙNÚT¹|ºåøÝÐ#«3E¬!Î®ç‚áýÞÙMª??>t2tbh´¯!N€OçÊ?0ÕýJ¿odGnêÎŠMÕÚ°=½²3QË5Åûb¾ÄÍBz½Ø(_JÚ±?rYàÒ«ZI«di-1kçuV87³/Ž ¢âoE!ÕYø6Ú'µíš¹i“hTÅ|8IÂ—tø‰Ñ(×>«GBß,ç«A:§T|Ì„rƒ°i#rˆ…}w²*é%ÙWtîÊœêØh8ÍQÉ!J	%\”MŒ€ù¬ñ"¨)!òV’‰~U—oxX>­B?r@Nr’]ÑÿwÂ{ò¶W9cž˜"€¤`©iò€è&ã?nì¿H§&3`D	¶rKïp‰lyNµÞžêwxHÆ…ž˜u Ñ„töm­>§¼ÕØº2]œh‚>XÉdÔ:’?r2¥{{ì²Þ¦@tª1ƒMæxÀÅútqgÅ1 6% ö[²¸)å5@ê[$°¹çÚ[I™&hà`2‘BðápŽûqž›a®6¢ÕC›Ö²q¡¬ô6ÈC".=M’eÍ¤qEEY!ÃDY$Œš‚¾¨ßuÌ£;ÊÌ|‡‹íKÏˆm«lúž8«òòâpžx•–*Þ¡?rhÖ¬ëCHi;9II^C5ÎQ?r:»ìSÅ¼ça¦KnéS@tõzÈ ’\'cIå!„”—žþX†¼èy	2\ömsÕ¤G°‰tª³ÈÑPIåÑØØÐÑnQ¸Œ4¡›Y¦YÚ‘3@‰kV’¹¬Ž¨µàè! 0¨´ˆÝE^NbaF×^«K±zÌ)3z´QûêVGÊáKÝT®í>Ç‹®«œ‘UÝþNbÄÑàlìÎsì«ø?r?rŽ€-å{¥øf`3ç:ç\ãS",SŽ`ÞD‡¸.“;0È¨Ë£^…‚ÊApá[m°áÃÜá±$ ‡VQ ttÝ)µŠS™ñÄü+½Î£yŠøàSèš(’ÍßÔ¶àòªk½Dý>àõ>§Õ[žu]j¬H†äáÏ÷·EtF¥O$ÓñÞƒ‰Ëmp+;æÙgdšˆw¤¢Dý“û/>o'àÝîÖD}¼×É¡æÐGÈÁEâ¶pŒRK–¾|„/,kGþ<ýF„tG˜¦LºŸ>½õ”¤­ÞÂL(»tœ±Y8dòÅódƒÝðü}NðÒTýŸÀ¼§AÅ@h«ì-¾òíôo5ðoQ¬ÝÉ•%(¾™Pt³[ñ«‚Õ˜=Ýœ»3òV,»0Ø	\@n¥ü!›jßo’3Š2îÆî/	+†O¿_Žÿ——YçV×tCÌŽ?r›3ä‚·á°¤Î~2ŠËOÝPÝåR¯jsî‰¹\Õi…`î?n«fW£0î>nÌÌ½yU°Ýø¼I…+ØeÌ•Îr%¹qHjŒ@†YÃŒáSÑdøã©‚Ö„ÈÒQ™×nb- ãko¬ªëHÌ­jª>:ÑåëÍÜ~Qñù™%ƒ¬‰K`lõòÐ,`H˜•bÖ<í”/ì¤FÔ£ÜU/Ty>ì´Š„DA·‚Å’à=±f¢û´ð·èsˆýîÓTÀÉgÞ¬„úÌ`ÛàìÄ‘{½a¢´_ußõˆñ‹Å¬"Ö”t§®ærÄœQQÉ¥È»Ü%îÊCÜÎ£‹•W”ÀÚSˆÚö²J[<›Žx¦dÇ4¯Æ,gH¯V¿‚JnŠAZÉãÃç×»¦“ÃÝÅ„RºûDœ.ÊØ°Zç4‡µƒhlqã¤®£ÓšžúX=Pl¯¢¦jþ¹}‰¯r^«kƒg§?n$¶‹rv›\ZúM¥ÜqXea{–?rA´Onn»+©—Šë4–Ù¦ˆÞp0ce—#Ñ åº7ÎY5‰ÒåA[ôK&•µà®b‚ÌÙv†ÔÜ¼¹«	û©Dû'¬DqÊ%˜w1Í›N9¡5rÕ5 dÚ¥¶²Áóëœ½îW®7¹¡Nƒ?0ZxUis#èàÓ¯&±?0¿vèœZÛ!ýG\ÚÅ­QÓŸÑð·ePt<úe¶6!¡ö0ŠÉD1RþÍ#ô»?rí‚Û·_ÇßTàO]%N¹ã¬VŠ=Íi/sxwR‡”ë:ùe‡3?nJÆ‘†yÉGÒý—“Ð2²à¤D¥9Gº½%«	8cM!Ì»¤…µÂù¬k²ÔúÛ.ìtÑ2eKT7¡jUàðx8e7£~°§^DW}ðÃåÉl)œèÓÉîsÒRÅúZ'™ð1žü¼'œî/ÙCF™7v¾›ðÖ°P)ã­œý,ý›M’9S<©h?n0Ã)[$}CFs–ÕýÚcŽs×ãç£±ÙÑFÓŸDÊëå;uWÝ¬Û‡D¬ÛaÝÛÓˆýv¾•»5U\eÝÚ\S”Üè¬BÙÔ1^áûÏÖÙ>Y.%&¢üµ"‚Ç‡NÜ£.w>VN4ò¯)Á<.G=Š(4[=?nû96Ø?0§´Zã&IÑ‚ìõuÀ¾•­/AžP&”ÒŽ”‘<7†°âîë˜æd?nù:ç=­5Ëã.ê¤¸«8½xëÏ‡®sHÍÒnI;¨PO"4e‰ñë:¼<¾<ÐÁu¥AZÉY??Ï€z“ì~>+áÓ»Er»qm?rv7°´²¶FÑÎrS"ËM”ËÁŒ@;t}7Nk´æj^w‰&`¢¢Œ›hŒëç‘¡Š3f(¬»É[¥ñÌÊ‡žNAœÓ;eoC@#Àf¡€O§GÑÏ^éŠ:ž5°x÷X¸s€¹¿Ö]bJQ÷ÿ&¤ÿP }ÏÒ¡ ŒP‚Âd: àeéPV ª*ÄºÑUQbªÅ‚Z~h=ž*}ŸéúØy“qðWUŠ"Ï1;¼\æÿ¸€­Ae±çÍãÄÂ³«3HÆU9¿ºà[‹úsš¸¢D@YŠÁ÷/Ýœpá¯#ÚÕ<JjCµð‡S!£±«u¶??f”( NÑ‹ÕDÉÜŒô¨2ÌXÞ–;iC¡•Ä°2<Ó¶§ÃÎj’Š"ñjÚ“ª	+j³	ÅˆSfu^³aDç2Ú­„Å–•ÓÊkkŽ,åƒ:šÚ1ˆ¨2hÇz_¸{Ï·×ÝÓÎÚkž^Ë#ð¢’ê$$³x:K$Yž¾3d$Ž-Ûï@)2ç«2&–P4Ï,bJJK¥`Î	ï€Î`ñhxë 2r%ôeü¡DµåU_ÎÈ9¬`¥¡ŸÂ¦¥ïì­ÄÍÑXçalÌŠï8Z·o5÷Ö‹0¤ýq~’â+ï•3\8Ö™×¯îþ$Üü›6Xüñî~ýéôlxSdê­›Y(/ß^€¬Ð 'yD%HÏµj|DLª+ÅöÛI¹”²Ø&¯ÖÆ|_Þâƒ9?0‰*|ökrtúÔG|íjÄ~??ÅK­CŠSŠtÃ€Ú—“Õ_¢a3Î_B°®HäÉ<#-XÃ²`Ñé‘ÌÏ„ÿOn#v4¦Ã§nF?re3¥à‚³\yg‡µ¨Œcpý¨;O´ý3:1h"z9GŠŽøM7ëˆ#üø±j	rphî58w_f°TÅ¢*Z=è õÆ±íÝ”íáª½LÒš’v­ý™ÜÐ®SÏóT‹+›é™wLlkÃ„‘ÜiCQ,Ïæ×>Ê¤‚íB¡¸uI!Ó[¶Â Ð•^ŽîZ×Ñ¶ý…¶ÎFü#Fâ"¼‹“'„wJƒ“.k›z6ï/Ó*1)ÜlK-a»œtQR|ê¹v¬ß\8ë™”“´:4¡´	‰!ªuõá×C,™šØYPÂ3Ìi¬ÑhÄw •µËÞ,¾{›ð¬à 0ˆ3ŒEhçìêî?0¥(XšWW“0iæ5¦ÍR}Ê?0±DÕ’j¨dµl	r‰úÂ:…Îk fÉÀ±ÞLúI]PžæjDð(²šµôI©Àr—ôˆ)‹\åÈ /l³wDŽµ»*²«*‘K±½ˆk)Ê@Ñ­Øù¡ë<‹ÖzýÚ‡Ì†R@U‘Ñsq¦ÚcØ]KñëÂ‹›3ïkB…h•*x ¥e3îˆ<tc;Öîâ…ä?rÂsÐ¨ÔXrá&×ýîe+W¡~)ß˜º{·‰êÏ'[ïèá¨ü™X¤Ï¡7œä¼Ù„ù™<R]YÑï<ýpŠ‚Ã”§æ`{ß»ÝÓÖ,ä4\S!J®K2å¢Îa²–Þ^™'†Oƒ¨"{Á¤O§üuiãÜ™ö¸Á€{üe†O8ÈŒ”(%PB2«¿œ§ŸÆO‡õðÀ-¿ª«uEf‰L¶[%ÆÉ%–Š¯Ûùøá¶˜tï‰õkiŒÛ¼¼¡7¿°"Ô„hébS ‘ïÈ>Ïá20­6zzÎAü¿²%÷r‚ðË¬?r{wG†EÑÄåÚ/åšFÂBHƒç!“Å0˜?nFð–°{[.ÖÒ›?0òxtV)B®ÞþïÊ2d¸ æ;OQÌE–üð
#MEô€³Ïë»†4h(]é	Ë{t¢˜%”E¨}²,ÉÃãö_/¦ï£=Ô ]6qÎ7˜]‘Ó– tæ›ë ²;åœ8ßV|q1„%RZ±ñHŠyûN$SŽ‡k í2ºg1Õ¸5±uôaž=`ÿƒmÀþý(èRÐ¾sÚ¿q÷Øù†+ñÃë€÷K??š¨‰hg´ñuðkF?rÄµ‹åÖçOËq•µ??1VugrÃ°šS0?n«PxÕ,û15Q÷jyu”þ??{¡,PnÈèwˆïDdýï_'Ùoèv±:Õ¨,amDXŸ~Ôý‹ìfÍÈ ßaÂ§ÃÑŠ0†/ÛÃÇ¦µšô|/¥ª^­bÛü?0q5²†d/vè[Ê8ø½z÷Ò-WvY“ÌÂ ß<ÏŽ›KéšÛfæÃÅ¥g$“X‡m?0Y&iS3:rês>´DÝ×ÁVYV½³,ÐŒ»Õ‚½iÉ›e›ý†¶;|¾/-Ê•Eöúm\ÄS*)APö‰<ô]<TzÙxh“«$Æ‚>ÿ9‚«Û¢\5ì^Ü¨"£Äd0J?rÐŠ™µ{—F?r6c5$EP9¦©R$ÁO>½DYëx<¸#@Ê°‹0lm³×ZÂl3©€bŒKËo]œl‘ "ã¡¾B0ˆY‚Vê8	;|”w±]v—HÉ><”9 âï"ì‹øàtL ‰¤S²¨&1\¡ŒWy¹3zóÑ¾í­²èÔE»ô§‡Äø‚7˜y²C„…õÑ;\B>{ÇÐtÝ¹´øž‰ÑUN€’JÀ¾“!‰VÁÂÈ(ù=o>¸±h[eõ$+H•ÄÂÑ™Ï@²¿Tê—ÆaÎ¹†ÜÀø3`§¡+õë§I§8KI,„÷rÖ•FJÄÆrK?rìI¯Ÿ.¬ñ¶íPC#„'˜Eyä–DAä ×ŒnßÎ¢MË|Õ3~Þ)ÃØµíÓøŒåÍcÁ ˜Ô%iB¤Ù7T·À@Š ¡Ø*ajCM[#²f×&€&ÚKÑÈ÷Í7Öµ±j¬£^<ño¿Uëxpâ³MfÖéPA`‘bÍ-*Ç¨F%S¶šùa•<6´š‘tüftÙ}Ê\;wølÎëE`3íú,}VÐ«®gd>AXÉ~;*8”â–*²ÙbÅTQbbX©Rzw…ÎÑTF$\¿<Î!lÇC^²DÐÀíÒ9älÙï(ÉyTíÒw»lßpÕ@g’²y¥‡¶kÚÔªŒ¾~‚ô)Ý]˜ØÛ¢8áÞ-Ø¢9$Ç°“Õ‘.Bl@õ*‡ê€¿R»RÚå>›êä_–9e®÷WÖæX!´Ú‘•i$*j¥§_#Û)ç8%`?n(²D¾Ø:Y<~®ì›‰*P%¡cy6?rô@Ö‘CÓçÊ5V ñòÍ\€¡fÜåæ2)ŽV¯@ÈInŽæ¥iÆT”òŒ[Þ¹G.Ad­ÃœÅ$£\*¤i(ŽD#Gfúb€d‡:âm°”wLª÷iªÒûÃ…,–Ïv§WuiV‚AëkÅê“Ç(˜äPºôÕdðh÷2¢£ÓÖubDÍªãžE8ø„!\õî'ª1PL Ò—¨Kf"B¼ÎîpYåËšCÐÉÓ7€â!Þ8Ó?nÉ„kMd$ÙTØÍ3Vå¥©E°ºÅ½ÂV(¤è5xMä6À¬°F m	–”íŒÕAUB<&QE×Nh¹lÙl‹hív&?nž*;8MžGú>÷yb2Ê0u¯çJùÚéš{“´)ÖQ§2Ñ•±F«Ní©@±­á§‚¬¼pfÐöº$(š²|õÀÿ[‘±o T¾Ú~Ÿ ½‰ÊÚ¶‘¯¤žFö¬ô(ŠÜ3pù4o?r"Î—mÎ¦ ßJÎLÚÃZÌZ??uËDÅ	Ü'é¼ýõynvF‚iP.¼óÕQð¤µHÜèR’CSŒÒ™³!§CYO‰ÌÊt´‡Ç÷÷Š©Êãµ*BBô5T~ü0—qÂÕ8Í»^"»??m¥ùÝÏ3®+þuÐú:Ú.Q¸×«­O»ÈkÁæØM•A<_­#8È×d°+&ï?0ð1ÃTàÿgýV }sg±‹†r~(&OÊø"c¤¸Ž¤p„GÕN>Ã–E„§àj‰	d‰Œ•‡Éùò3àø‹ìkÎé›×,ÿè^Ø@‰M_PÎ¡$€‰@â9NÜK“8ÐöÕ{ô^öÇÎt—XAÞö±M$™Fâ…†bM)â×‘¬ÊÝó±BXQ„9Ø+›(	÷xfq1O~vÈ&/1¤¤ÙZ³/;NòXŸ&´z‡ÿë:{AÀPª³r¤€ˆªF)æqäÏ,­'?n|9ûŽ¤ŠM˜&½´™±¨’"È'ªƒj‹\Ð'¤®\ýþÝ‡L	$@é‚%E‘×–ÊÏ È!¨wñh¡„‡§zVEŽB‡¸C$þ.ñCØ	¿MÜê¢|¶.^¹ÇÙ<"I# ÈT£YR ‚öïG‹Çõ¿/cöÿ­ú°ü‡vw‡—–_w–kØ^G–yÆ?0¨ƒ$D:B„ŒŒLƒ…T ˜‹"„\ÙÛ¶[c’à!	Çß«;‚WXØhãÛ•ØaºmvÎ•vÇv5G”¤(}WÿÑåˆûÊCÜ’70Eý,¢ìÏHî¤“€xÑÜñ¦PÑFQJ>ír+Ÿ³Ð·›zŒÿ˜ù€®ÚqÌ>p_·Y¯aËnœ¨€??*`uœÈ©°Ëó·ç:·-¢ÿ¼_oß€ºõ¨&»wÕÀm÷ÜÕµF.ŸAô‡‚ÕåYÍ÷Î )y4è·Zó8:Ï6CaÐ©mÍ’n‰œ5E6Q®}‘sÈøOˆÌ31*Ö•( ˆ)rQ™nZýÙ>ÚöÉ?r^8hHBÏLh™¯V®q@ûÑ?0–>-.àÂR†½³.AöTâ;¬Õ®=OQ«IŽœî¿^Æ¹Î^°²7ˆO	Æm¢1gÄoY54îëM], <K¥ŠüÏ¦T)ÌsÄ¶„ ™ùÌý¼6ÇbEsã$ü+×°àHõ”:â¡¦Dl{ëBŒ–ýÚæƒ)'bÿouŠÿ_Xë?n"ŽZ¿B*€¡Mªˆ‚â?0³yfŠ6Ú;C&ò/ÍÝŒ±[hTõm¾7Õñ×Y„Û´-ó²?rq¯w}¼öO¼;Á#.Þ¥t´)Ì†6›3Þw À*‘Ô#Foä0;9xßËë¾ß˜é8àpÝ-LAñ„éŸ[ëjWšÚHkrôø‰»¤æ±;[HN¬Lciß{ŸB…n163V£»÷öîË“'N:z«ÇÓÙ³hÛC1Ç§Š[õx]&1±ã‰“8ÏÏŠ`‚?nL­„47]ÿnJª’PeË[­ŠÔ¡P©?r-,„¢R´)DÌ8ßO_Â-ÝÔGKcÈÔ¼’f(ÕÜWR0WõÛ©¸…325@¼6ì‡o©#WŸG‚yKBßÎðÛ^C]Ô<­~¨÷ÔÊ¤aæÍãÎ'Ûâo?nsaÉ—;å??ªJ9äúÖKö­V_|Ï4	i+Ï¡¥Ú(BÊö]ŒÕS´g.è“vþ>Y-öÆÜàïÐV±°ÐCðÑµã¶ï®¨—ArÒOA`P+ßÖ•xø¸@šAòëBOM¡I·ƒú„§9Ì9Yr€d‘EH?n?rïƒC˜;ÜœÎJ+B|{94hI^bÌ«,…B2ÄP&îQéhÝ´SµgôG·_t?0oë,m±·@Ÿƒ:d²iÊ¬$%ÌÏ†c¸	Z¬÷ŽÚY˜ŸCdšKÚž\3@Ñ‹Q1 Ø7ÜÍ†tœÞœ=8Nýû»ÆÇyš×éÖ!.GGJO”¾Xj¢7ý4&™Ùôæ4˜®ÊËÍÎëÍæwžY[7¨ŒbD‚³¶»Û9„N®,îE8?rˆ€Ë‘¯^ß0_ûµÐ@¸»±DAùjÊÜê½f\½E²æ^ïÈnÁVÒvÛs¼%{zç?0]éª$Kmaœ#f·èl&\úb&õk¼ƒ°[Ê¯–)áXÜìI>¨Ö<<vQe‹9ÐŒý‹S—_——òYºÊ;çõëÈ_ô2o;¤1e¹ik£ñ¾gj}XíO² —ÍXÙ~}UïõøÎ‘òQ¹l¢?r†möÞÜMß–ü'jìÙ±¡ô€&þ»F/Ú™°¦E_°Ïö8þ¢ó#æ®I#ª0s‘PÌ\(‘îú Í´±—Í›:þ3‡§eB<ä¼<zsî€7:—à/¯7˜~ãŠ<1µX%R?n$O¬dC.Tú»ÒÑ(è«j¸Q>gÝâòê·?nÀôwLŒ­Äñ¢‘pãJo?0ÎÄ‰K|ßŽY–”×mX­a\@;ÚZ^?r&?r¶5yP^8QZ„Òo‚œPÙj:y)k@<¿w«mÛqžQ*·è-û½ïKv’acùRräË§cáŽwóOuõcùa~_ëlŒ?rWÙ?rmÝµó½oƒx4è|\Út?nB"¶ºD¥ˆ¯×ù¿.¯WçümãÂ;Q>ö¢OG5MJJ?0’{®ºz¾^—-hc?rÖ/ÛÄ:4Y}N£`ÊZ(Ì "?0‰V2ŒMAþNï'…8ïð½ì ±-i/:²@\€S)Eºû[£ÀÀ)çÃA<<#¢w—¼·yÊ(nYÔkÙÍªé½Ö.×j}ŒyæP;FÇ(¸‰Âª…âRU‰Îc; bV’á´m™Ž›¨t³	²vNá(íi`RMêÈÎ­mxkñªÝSÂ´O€QMQÁ??23ƒ#`â>¼³íY¹3È+ð³oUoË¤ð’÷ý/n–eíYÇŽô¤ -9³IèØr°Ûs‡€Ê£‹GMóæGdiÇKËP*ÈÚ0ÈÀ6’2¨]9pmbG&ÉQÍ0ÏAí‰ßE‰¼—3À‹qž©gç%±Û—Êôœ’lFQ±ÂÂng1ë*‘¥¼’8ôŸ“E&:L¤#Õ?rÛÓÃ<×8cÆ';Mr5MoP—Ò­‘G…ËZYmúÙödÚgß¤	X;Í£ÄgÓ­ï© Øø÷sŒ§Ù‚×±>Þïã+pÍ¾j û	¶6<7‡‘ãD‡×R'ÞEjr™Äî–ÐÐ= Wiìè½c6Ê™€é9ú­³/–ç5Ó®(ãZ(×¼8°ðŠmR¸&ÂÌÖA¬ûBôKl:ÂˆREÈfÏUà,Ç]Ÿž0™ñJ–—V`»¾ß{éYjÓvÑEÌ¶
#hÒñÜ5;×Ë\¨¾/u’||¸N|1¥¶æ‰6ã¬S&f×º€Pê‹ÀW)¼¸ÐÄTƒçï>×[àUúBö—ž›?rL·+¢é¢ò‡óíiÃH¾ ñ`}a#,C¤wvð÷ñÏ+ìFuä¾>¨‰)±Xveˆg±É²›¾iß¨É3lmùÛvµ#5°&ûÈºO·« ŸI+ÑæÜ±ÈÝ­<šÂ¦Q;5=ÜáxsY ¶ÉÏ›>¢Ã«>¦ÒC`@„„Lh¨B,dO-îÛàûœ{Ê/Fž	Ÿ·3^UNm§é¸ ¢¥e€“F\ß7•ãmÒD6¶¢ •¨àE¯:ÓaåbA§¨ðƒ|,­_aƒ:ªŠ³ØÍ²Žf)Or$ß6?nP¥eSivì™»»"%á×º­ò»=éx]¤ˆU!ÊP‚jQT\è¹ïsi}~®ÅÓC•³ë&1Eu9rjkN%ã'ªŽi;†ÚÁc:lèøQ½¤!aDT#³¼.¦ýû×em”üá#mµkëéTÄ±.™<3:Û5åz²z¾ÿo™ÂÎÙÝúDÅé	§Y8¿#ÓAšuVšá³òø|+?rª.E+ßÄ:¿;NDüÏÅ‘ Í*sdš_YsÎAŸ6Ÿ:3Èh¬”7e9?r9µa{µàèÙ°P+Á›*«º­Œ*¢Rˆ ç…$}ùüÅƒÖH›Ï¬ž¿ËŽêÃBƒ~Pyß¸‰Cg¡­»k3qK¨¬duXOVò…	@Á?rj*‘D¨SV?rÉâÙà}rTq­\T­}‘uÀÞ[û…úýds^vðkÙíEqŸ/uêŸs=m'Hx6Î×MGÞ¤(&÷¹5×¬Æa¦÷@{/¨‡—„Öq>&mÈs)Â/¸Yªò>ãLä”äS—^.àQri‘ÅÛ¹o55Y˜qì,ôÕÜ)ÐÊ ‡g×¶-NÍÜñ'??=âäR]£ÖÊ´:ê<°Ò½>®5Ûçxz6”Öc&T•=H‡L‘…uÎžnkböFýtÜ’}R¡ŒlI³&eFÚ*él&ÛvJõõFÏ808B1"FâÄmm…Ž{i±ÁîÀxJ((ñë÷ÓëŠNDÍ v™˜÷g¨?r0pFØH<ìáâÝDýQ‡Î¨òÒÒ\·¦¨ÇXxxRÙr÷}×‚ãÑ,Ü•½üymˆT*x—ƒÍ¡=Þøþ_ù“bªcg×	-†vÉ÷äˆ==ÜÀGÇ¯+6Aœ)€ŒÞwh´iŠÑåè›¿œ)K?0û®U§ÜdE…$@Þã¹Ü1£t1—Zð]–¼ï p~‘1žç"ÄrÛNëWÓ–`”èüzã‹½~oÃdâÁú??%y[†š7wbý+§ÇLî‡¦a›’»;ç˜‰}3á¦IÎýL‡Äâ_‚Ý»·Ö·IŽMJéÑÒ#¡™°ŽêRU€v•ˆŽ8¤Æþ’©¼E9kÂsC4VëˆÁŠ/Ü±EÌä´]r…„Ô04›v3ªïz­y¥ÃàR•?n ”A9F›¥P2â–E¿0Í>!„yV:ë†}1…ŒRA??wTwFÍ7B†pùVHELP­Äu”¹ºš€ˆD¢Ím¶F®È¤Ó{§Ë6Îhs½?rµ=wñ¿_”c1=4û¿¼™¡Ç¦ïæéönl˜/¿ˆáÆÒ¿<».?0ø§Á—H…›W{<Rˆâz5é8ŒóÓ¹õ2#M‚F- Ø˜ƒ9EªœWˆÓ Ë°£¯v™"ŒU"·Dbrn«2Wå‡U;>J¼Ó'\	j%ð÷Q…fBÒ»¨žó[)Ãñq¹§I•êv9~òÃ#d=åC&Áµ”j|8®™uŒ™—8Ÿv.º*+(‚µ‰,z¯!ª?n‹ Ð_Çö£Ú9Ç[y[X”¡”åâSd†—y©˜yÑ€caLÖ€wŠ	t¬¸6Y=Ìå*Xç›T<ójƒ*õ[áÖVÜ%°Ø€Y™ôŠk¼ÊþI@‹-?r7ªÕjÖk$†5Ù›‰ôÏ;ÄâLïAÁ¢‘›$²JD4ím–Â¹æãðêßNNØÓ??á'·&šék8±tIÅªoê{ç*Ò›s¶K&¦—®ýá¯HiA°Ï‚?0Ñ+ta¼]\arÜ?rË½^6éD¤¶¯-%Úíx?r¹ññè¹u’Õ…SÈ®Ói½²?rØ7)DsA×à¸ÅbÖ½fÒÆ“çKS“K¸¸àôÍ'ÃÅÈËWJÊ®xûŒÀÛ9#”9S©ÛÅW~Í¾’ñÅ&u„«"åÀf;Ê2Îþ¯®6£ÓlÜ-sÑý¶A¯¥Ç´-Ï:ïq…§JËIƒU¡ˆ±ÐavÖk3×J?r)…QãH4Ü#"+¨Õ=©D¸K	¨z½òÕ¶„`º$.:ËHj»-¦j˜—ƒ,Ç	¯¨< 0<;,ÛN¹ÜÙ0Á×²)sQX´DÀ1vfÈ6‹ñ|wà’™1êµK%XgŠ!y]r	¨ªšuÓ™Ï©µ–€ò¿ˆ¿]¼u‰°ëÓ=*qqÆ$0“ŒýRósÍ:Uã„?n­÷qÀ¯P]´ë·Msßm7¯u«	Ôaj ¯!'[Bçc‡V†ëx[#Žç|’jžû¢—ôäËhŠ$1 -°ŠL×è}’?nªÛ’H¤xZ¶Ï`pMr³=ŽóÛS›ãší™ŠðŽXÙ½¼ŽÇ?n3l³H•eRT›êÍbGË7Ò¡ÓˆVfsîQÃÑ\œh0Áƒh qÝ)Éër>\páµ¤eÛ‘¹æ_	³pŒB1zgXhŽì–Öê1M«õs¬ŽÀmÌ@å"í/AZ]•Ø‹$.|Ù$Ý€Fa-J­tXQ¿C„?r•Š«e¶/ÃMå\µÆcï¸p¾µClÓ–±–?0pîí¶Õ#…o˜¦“ê?0€7"Üb{d©(!`îC%qÍÀ–KgÎùiÐ`ÁR¨B?n4ƒ6¶ŒlF,X}UØÞ¦Y”aÏZ†ŒvïÂÄ2™)É›†AbUÉ¢ª:z3M†ƒ¢ÈÎA¸@í0H—óüj—öA:Ö9ËŸJõO/œùÎ}œõ©otƒÎõ£‘§‡DDäo3F¢ø÷äy;†¨ƒL™á@ÅªØã€g)’«£ç»[Ëx.›@Ë¢j¤Ý;ÉLÔêz	 1»µžÀÜõ2¶Û?roêÚCOâ)à]:·9>ôóGæ ²•@èíû$<ÿó~ÇÑ—°íÄh)5µ£ù½óŸ??Ûè	@„|Çê??N¼Iû>§Sd7ñÌ›oûmdf²Ych¸`‘4—ûñ[Ï<Q5Þ]G3ÓD\%ƒÍú´ÌŸHƒ¾§+Ù¡ý)KN#â,7‡ÙÞ3¢<£÷„÷Òö0þ·¨gÊ{—¶¬L9l\¯¹\öˆ§4A=¥?rÙ*‚ÞÏxŽÝÉ®¬Í»·eå¦ø|[rá7lq!ÃŽ„ø¸`õ§OŸˆ1ÿ3¸’BFgãïdSPÃŸÑ°yHALŽzdˆÊi#ÖI·«9;vè9:Õœ#îËÖÝ½#ŒtøsruÎ"$—‚I	&în?0B'x„Úô©2KOåDÈ›B	Åë±;DOÄwK¸zÑÑóê¶·ÖG6dÀ9ÇxÀwÐyÖ$>ÓMq µÊ]??Ý|«M;$ü<Dœ]cgµ»È‚?rÒ•h|yÖóÉxÏå/“’K³¡q„@yffaù˜°¿“*;aÐ*P˜C×ëBr†©âQX“—h0þž?nÉ,Ìq8eïõt˜|¾ºù˜yz|£Õ7™¦Ò}]~cˆx‚£Ây+"Ú!d%UAB‰g”è>9nïL‘æ-tU¼Ûñ¬jÚ×€\ñØ	 ‚M•$²xùsü¾‘à4ìäÚ"Lcý©Š"	Øˆ˜?0™Æç®Û}ÍÓuŽŠ¾£wÓ÷¨ÈQ¢ˆw)Ð'êÓ×{D©Aî¦QÄØm¼b<$"ËôX]^ùîüPÜ?rÚCß'~OÒ#%úgÍ€>\®¤ATv(áâåF,’KßAÔøÉcƒ~ÎÜÛÇ(?n¥oIQŒ•ñÌ>o#"Wàñ8vyâÂì²æu?0òþò»¨=b|½ûGÐ4§¯+1¼?0Š0	D0¬´rŽ4ÝöÒøþÄæ@Ñ$Í}¢îßô¤yÎò"(0k6)»³(¬?0¤eòfàäÊáLÒö‡ÃmI˜%¡%€v«(äº4eh4–jš=t\•€˜ËCa•yëÅˆ½ãžvnìÓh\dÞs|ÅÊÎ!u„!¨jõSçù>ô˜q<pÍràDë³nBý•El¾ð‚[`Øà$Ü²–¢±l£JXW8|>¾½W<·£¯º­{XøMƒYÏ@™h=„"½t&Ûåöâd“Dc¥+¬bç`ùû¶Ì	ŒÑÒ#¬"h‡(HïhäÀ¤=ýâ)ž¿`ï‘»¬éD°lHlÖãõgeÇ%çº`4¤#¶ÜÃ©zŸ6Òœ³<ÀúåjéXWô>–(÷;ì?0®±›•Ý€¿7t¸ub$‘OÀÆ'É‡(àjDM²»Òö³'ŠýÖ±í}Y?0óíÈ%ˆOXìZ÷?n¢3Ì_ÞcDLmÍuô{ ˆ3??{ºR÷oêà{´þ°„×Rýh’ƒqÁ0bG§:ð¤+.ã¦I’ §YÎ^Cg;7js$ŽpÉ%n½¤UèˆvMÏŒ`ÀN˜Ç†Èn?rÃœÈç;˜ì“zÊžãr`È³LÚ_¾Š.ßðÉ8ÇÃ"x$n©â;.ÃN¡›£/Œç€hPliíùÜš¶Ù?rÄP.É,ô²ö±\ÍêNwçSvchë‚ÃÀ^¨ÀÐšÛ·¬ÆY“ÓÎ”3#ÈhlúsÉ‡>²«âÿ!¿£ÿ©iY£RÛÃ-ÿG‡Þ(€ŠÅÉ ôJ¥·!„	OÓŸ0çi×3ÎáÙYÔÁ†€šFD%ûlªa=:…ÉY.?0yÀT$E#',?0ø‡œŽÑÔ[_2¨¥WRb­U€ÏÌQÖû«')£y&…M:€›ÏÃÎÎhX¾ž„maH%ÈëD¾ïÇ=)ŠjT©´“ÖsÏ'€ˆ6Âˆ°Ìü­`•#š@®Õn×ê˜"rÑOªžî–³íjÝ­ÝñvÒ9NFÆÏgB²‰*€qg‚/O-€Dš{€+*“Ô?n…ú¥ö»åE xÞoÛÓÿÏ°Ú}¨Rt^¿0âZÞ9¯»C/Oôø}oÛH”Lè§õMëþñ»6u(È A`Þ&j
#ý9I®»üî¿äe£ªøvÎB’<Ûë2©ˆûÐàÚŒ‹Y¥–X?0È€týdåúöÌœµ|GÛ½ ¡€oÔÁ€³ØíÔ¿§U³uÄ-ÚëjmMN,Àdˆîhm±¦V²*›Ð_ù[ëÝÏ­2¬¯½·ãºtÅF»ºÁß¡»÷¥V}î/BÞYÓehÅmn¨_šö»*?0Ùä¥LÆ)Ë«ciÖ³Ìæ6(g1œå0zËi€´…Øªh‘+†7‹›8’šo_A0‡V@IBTíøÓññì¨ƒ‡Ž™ëC¯t/–j¶ï£‚oÕ{ôÁk0HÇuN§hõõ®ÿéåÒV6-Ÿ«Q??¢7ˆÇNË5GæÃ$ÛwTT,¸k[åqÈŠí ^bÊyèk's³Ÿ;Sž9>/dÿ“îU‹ê€?r04GŒ´ÈÚ¾GÀ%;À¨Û¢4uòÅÔ×;áØ©þðàÉPcØ¢‚¾?nZŒø˜	ûµ8KàR+9ÍÊ¨pRW–NãG?0ø#•(ÕU³’ÜÃß—_±qzJTf®¬m¨Ñz{!Q<„´eÃ¾Kv{§¼ü—|{^Ú(ÉäZOkb‚&ºkù¼ªÞºô0hYeB…Ö²ÏÀ||Vë­]±r¬³"5€jkY‚)@Ä ¥0ÇCî¶f†ÎÂd“ãN‹ï•£!A;~Jj¸£ëdT_üúÇëxøEJ©º°?rilŸÇ·²åý¬3bg¦'ÙY¥Èpe!ý>OŸYpÂ‹xŸÇÂÂx‰Ù´Vžçæÿ£'ÑÇõðöüÿ³éü÷¦Ø‰»0±˜½:OX`îùçfVxDÞHø¾fðºôŽ“ÉmVµà‡º#p%D…HâP(Ïqi<=§©fW—h°b Ì²«û”ÅB‹C×®ÁB>¨ÇõPªÂ¥_ÔßËB'ÀO¦$cHÈ’	ü`ý<gª6æ~.»^º³º,ü½ÅŠÍ«(AÚ³d˜¸¸û)ùäybÀˆß>@Ž[Å?nliÀ>Ž—™æÞöáàÿM†ô¶u¾þi0ƒerxò¡×ÊP(êïÌ$Ñ_Òp¾µÌmó~µ¨%æäHU5s §GN†´4ß+4Ûeõ…v}t±¡D‹çêPùŸl»œX×Yº¿V¤†môJCO±áaÇîþØ®ÑFžð=Î2Áï$åTcªRÞÕw«EA†ß„DyU^ú†çaÞ¦Í6ÚÁÔ'¿øæh6ØÚ©ÏEDà.;³4ntyY`=«þ(¸?0¤XTV!$¹ËáÜkðêTïjï«tM”$ˆSBÉQÜwi7,Ý©¼/)´Üª{?n™P0¹EVî#›‹ÿl/¸Ìî¤uP¡¯¿/k“3;#âž[¾¡æ»·÷ë"+Ø‚«—^Ài°?n“@aB¬¯”08kÛ	¨Ÿ(@Ý"š^1³#™õKf?n:[¡ý{|î¾??Ì¿A¤h:'ùr¥b$+þ@?n²¬U`-Ã…›ˆü	ì2PØÈ~÷µ?n=×ìû(ùÃö‡á¬zÇù—÷ûy§õð??•ßÐF??Nëì-r¿³ó›“Pþnî5>·WÊ/[Ùá˜^Ý§bÂ©é-kxSM-ˆ¡?nË?nËÿ&ÌÝ._®’žØ¡ýx¡j;ZÐògðµÔ??®nˆ/¾ó¬ªB?0@…ÆJÔ°šP›¦¯=¿1ÔýÃÄõÂ~OçEU‘I¢}¿¸—Ïys<éÝ!3ÅO>,rx$œC“]d	ï;·]>x~Îèo±…Q­+l)ãÌ‡ôvtÝwhZQ®77$¤ÁúÆMÊLSfÕ±±v¡°^$ú›xNhÛ²Bâ¡ï÷Çg^dvwC‹ÏkÚÌ c˜d:ŠIÄd:õ™×%Ûàh†Öâç™ªò$	T¥ÑÌuu E1S]rÁcd¦µ‚´äŒÑÌ†Š-wš‚‰a‰U?n?rBJŒF\G™l6\%UÅ?r"H»PØšùŽ\„Èˆï(.µÓÁ?rfö&\ˆ<QÍXg™¬=`ÆÓTè 1ÕRHB,’#»†ÄÍºPÝJSÔiwfM†¹ ¶!š?nÅC.m{n¡N;ÐS;ÄY µL;•WÏ!úaÝ#fÄC<«7sl¼uqð@¶õÄ1xÃ46k6¡œQgžIIÉ-?r»‚dS¯jÚ7d`òö *xÃ>Dº»Ð2(Ö¦Š²Z˜?0Qu¾z¿Â·N[‚æ®;™Dp.tÁn¢\èªˆZÊ›?0É,éS?0É”åˆ¥D‘=(è‰1"/¶%ó}2ú/U®Ø¦»É³Ý›ÛˆNÿS¯oŽ5ã³ñûòËE3nž$¯o›GŒéçÓ6ï¦Fy#fl¹vÓ6]þÉ¨Ù5]Ý²?r¯È&åtsêlªÃÍâúxàƒÂ.nÔ‡ÜþQÒ`²²VÁŒX,Q@¨T`©¡ h_Ÿùçáû·ûÕù‚,ÐÂgà'ï¿°»OS¤BgÌÔ“ØIö´÷›Ï;Xx–¹%GûO',ðåô2Zm°6¸_ÙúLþ:ÿ%ÏÌÃÃ‘ÏÁ4¾ 0Ä Ã"†<'ÛŽ:¬??²—ûîˆÇwï‰y²@#tF\aåÒ¾Æj¨ÃóôUœíÙý3õ˜|4Õm—Ýß5¥2VR$&Ì–ÒhÍÃ7ôËš£8¥N2OöYÉ§Óý}Í±6ª¼0Ç&°ÖI¥®œŒ¢Jd2ÏJ)˜FJl]èÔ†ŠuXèÖÜ«¨ÆU%T9Ú6ì´%g/Yb‹%Ýˆ@Ç(6Ev‰néƒ”Xe]:ºìµR¨©ÍŽ“,.Ùb”4®ÝŠÃ1mÏ÷áÀªø<@ó9ë<‹'ç±Œ~Š8èì	"Øã¦$Û¨9<ŽL*¦w‰-8¥šÚæ,pa¢à}ƒ?rh4”X‹-€úyÍHh6°Ð„u¨u³1 ‚C=ÐŸ/žÏžÈ»\œQ )§f•ÜòqÜÖÒwÄÜ†+&¦Ü<õØ½èdÝ—åCÁV9D¯ó|³+B”2É=‚HQºk•Þ©Õ×&-THó±ÎkÅ3n%È“b*‘ÞZ²ú«¬NÚ7KMn©™jVÜØ‚»n¥jå7”BI$egŒ¼ZLXíÊî‹¤÷4¹[šïæò¯$¨.›è²o¾V.úÕÙI¡ªlHhj?r	2ªN”/8Ô"y:V]Ä•XµØÍct*'Mçôf?nÒÜª›|"v‰X$iª.E¥UÄr¦[ÕÙ«ª]á\²Š‘hZ$±&án³—~Óo	5«²øE’ê²¸y:´ñ:™P½S5‰©eß‹N6±ŒSxdÍpí4³(«e¡”¬QÕ#ª¦CÑx‘‰½°7/Ï@Âjämê\¢¥²íSI.\QÓ¡ tPÅy±?nË¶cm	0”F6ˆ«(ƒ­klD¸?nKÄh¦VcŒ+?0£–Etjá¤¼ì?rgä;ÉdŽwÏñè¨*tèMèq¦¼æ‚4&,0¤š€žû½§¹þwÑÓ‹Ýð¡íË õï)È–i&ü¡°ï>dº ÏuÍ8¼ƒ,­Uï*¯ÂÄa$¶Ûl)f¤ei°bbØ¼yì0æÙoÏÝg›óÍ,û»‹œÁó¼s«’Ï~B+Ò1ø÷SÀ"?rù?0,=Ù5éÔAEY Š‘@E‹€à…MÃªHý¾ÊHÂShÅËb†2të¢6ˆŠª©‡u¦†H\eÆ ÏÓw¦à4ÒY½&AÇùàˆHVoõCnêàA2”À$€Ž¢ñ,HÇÑ¦¡õáâAÕ–“êñSxG3€'ã•ãÑS'"MÜp¯•°¢ÿ]ÜÉ&D×0XÖöZZ,.PRƒ7ƒ¬£ $/ßKbÐ??ÇXAâáoò„ÞG‹Ç^[/d0ð”Fx‹¯LNoß­P§F??å?01bØ©Ú²#+8R4pìMj…^€ÛÜCaÖ-áPj5â‚	þ®!‡0ÊRäA+??:pêj•‚È¸º°‹dõ°ÚZ(+sÊÛPRÒ§„Kˆ@z"rr'ç¸ÇPxöxìR`êˆ	Ô}R0-?0ìçÛ^XPÄ9÷ödó	™”¥+¢N_p:	u¢_”ãËo=o,”#$	¢ƒ”±v"Y´!#ÐWh[ÃV‰»Ó§ï4‹`U.i×NkŠ¿éî÷Ó·Ç¯õZà„±:%Ì'¶vû›BG‘5“•ëGÕ9¢ÄA€ˆ ‚DT`ÉOX{KmH]±•28!š”E%…¸Z8c«ÄUžg`ê”+“Ž(†Â É™’íN¬+<(`ˆ\ÖI!ÃUŒêË1,ˆGÉâÃ±*ØY²ÛiÃoˆLA¦D‰(,´)!C@ÕbG{u:Ì0øäéÇjd£Ug\+ ºôl?rêöÐw“äôXj=ÑGap<àŽý¶øºgUXÉn¨Á	»=î–6n²ýC<€…›FÜ°‹D‰&”Æ(jãÀuáØ»M¤’ÞøLŒO?r0‚}T¤ùôB>¾ã?nâÈjÐÁùõèäŒ)„ß2’Ã^Kº©Ü_îøXd?rXÙ¨TM]c«ž:ÌZÍÝrŸœfŸ”<'–Ž÷¹0H_àeÃt+±4’¨’+‘*§B¨ îŸä{ Jì?r*6!ÿ$àI\Ó"ÀŠð~|˜ª÷kß£QYß<ûúGðâ¶_U¯<­•òÈ]#?rôâ4þnjöwnÙŒ†ŸÈµ¤òy5y©/ª:™HáQ‚ˆõKÓxæÙÐÙ¼ßÑõOc]ü¡ÙÓ­„==¾[ê÷np‘g•þ•ž©Í™»ÎUdå‡œ¾‰¯PÛé.å™™??MîgÇ8Ê;ÇU5mX”KÞj«æ{¡˜DNZå!`,1¦6*¤-V.Ã¦2¯"Í?0Œ)™‘¨\ÔŒB¸L#u~õç{AÆ(I–??öyUü€æC¼ì`t ”½4À=Ë—}ãÊ"{28	¯D‡Š¼Ç%ä¡¹ÂzHc{O?n\zü?0ä¼z˜eÀhfg…†@Š•¬¡ûQL›aDm½éCkÞ¦/H()ò(¬ãQ!’ñÌ	ý¯ª4H0HIIœ›×Á<¶sÎÝqrF™$E]¶ÚjW;HcÄLi0k9½à(™ÂFC³=fíù^»Ÿ\al‡¥%·Cõ¾,LqâÈ¥¿FË\ÅÂÉ½‹ „b?r˜´
#ç“r°¾A]Ü•E£ÎT"gIRºJV™ØÂÊËf‰c¤Ú*V«B™wÑÎÐáƒÒhË°>`®†®»(RYKï©\!"‚õlt*·M{²?nYLèt=T7:smÔSÍAƒ'ºë±ê0„jaÂàúêPg1wÒ	åS-Å’Û²‚ü¼I­÷2ßÍ÷©$ß('¤-âyKRóaô§{<ìuÜÂ˜á­\Œ!ßÝ£	¤:–Z$9ˆ`Ø ƒu®aIðŒÍ~â¥!æÔµÓôGËUÎÿ?0Œf)³dfV×¢“³m*&‹µqô?nV‰'‹º¸pŠÔ"s§À<¯-«»??ËQ7„~Öý•È÷[Üæ”‰€ …¯jÞÁ¦ß¹ó¹ëê“$Ýi^zý$übOJo·Vgg¶„ïgWBû›ÞÇu“L“äîÌæÔ²CˆÊû–ñŒDu KƒLiB&_EuØÖ,ÍK=2¯Êð´&GM!šÛ›ÜŒ„“…„Ö<ÚYN¾Q³C²Ä·¾HJ­B{a(a½¹ï–›¶Ï«‰ZÄl…Ã“ÉØ•iP£Ijý¦f/dVµ8g¢";va7ª»ñØ|7ÃW8Ú=¦Bº›C~­Dù/õyM1ñÀÏè€*ÃoA©ÒØo~Íá†Û§T¨BzµŠ ðcW¤$Ì†ÄCeÅôÈ]wr÷+\­ÐmQfÌ©³üP{fQ*fŠ´Mq2 hŽGÀQúy–=­/m*ñ5†61N;áš.<*QÞ0\qác??æ2´ö¼©ÚtC)ÞMÐP2ÝMä˜T1ƒ?0†wÐ¶ç6WLbóúSÎ1@8<¹¦ìÝYžÜÿiìÑÁâÖuho	ëºMxXkÆ-[‚AËäïdúƒ¸éž·¢‡ð•-CðTÂ}¤MŒ‹cÈ0C§bÎY4¢ª‹,‘@¥,BaòÐ9è`°ŸÙa±‡põ¹Žd"¡™pX«"*b¬‰'›éa£îõ¦ù’“‘Äjmðå<höu‰üÌDÚ'`bÜÙãâŽÊk¬4ë&ÜÙî%Ô,ÀâÒqm6û“‡‹?n(€XdIY@RƒN XI©2@°"°±$HX	€ø/`8ÈŠ’s¿²•a…R)ŠÊ‚ ÅˆîÿnÉž‹V=|›¾÷r?0³RÐ?n°Ö)”ˆ¢Ù¤$AX+‘…R‘dO§5¢-‘#+bü¤Ô•„¢+vÀg@ÃªÚÕ7—úÐ,žœh“Ü†áõ¥4w†,aÔ’,&‹,žß.5¶q»`ÛõG©³åä*ì&úü›fäRÌ×¿€nÏ]ÀãsŸ7T¼&­H&ÈX»"×Š*=&t>C7è‰”í’0˜„BÊ=œk! aÐ¶Š…²	'y€Ã`RqM›´ñDÙ›âÊ>Hž„Ã-^ÇUceƒ._-xëû/äÁaü—ûýn!ñ÷a•¢ `Ba®þþ™£Ä“¤¡ÊÉ¦À2ÊchLP¬KEXØšk;Ièe¦¨îw¨b%é÷ÀV¼Ùà‰Ýa„†™¶Veß'~¿xQ­èDK…›%ô)GJ'dË9y}¼£€•‚ÙÊ°"Ã¿'iØJ›*HMì”!àEZT8•ëëù F6Ø• D?r¶8}°³,kª%H:¥ÙÑ?n&.‚‹ŠÅŽKŒ‰í3I&˜¸3Ž”5Ð¤?r{<Ôï¶{ Ælã–ø8ÊÖüõíÙÏì±Êe¦`Å?r&6;ý˜¯6D?r!ÞoÏ©Ø½økšé½ý6ÌD¤(tG¨Àb!£&gHNäZB0f÷çÃClíèx•í³c%&^Ù8”„)a¸¬ôÐ(ÑJÏ†˜)Æò–7?rîå„Ñä›ré‚Öä@¿+^ƒ<‘KÑ‘ý°?nE#s9*?nœ$¡Ý ¸6LÂd] ŠŽ[rDÂ@;§Õ‚£‰Ù ½ÈÄœõäbO¹EÇM&a{Ò‹$‘;…4/6ë”m §èÙ­ñ‚ÃIÉ$ËÓ”)£Eæ«ÊÍ¶©ÕH{_§:9w«…n6DD†;ø°×¥!ÜEÒÅj"L*­4£&â¢)+ƒ)eGd˜&¤@ƒh`‚p/u@èåƒ¾êä·"rrÝ!ÆG¿‹bfú~Nì¸°(¡=ÅH1ÐÈÐù0ÏXuãTDuñª2>¨©?n5¢&ÄŠO–jø~\Uâï¼M`Æ2R?nT1ˆ‚¬0AçaÃö½sºl	.C`òçpò:i$ž¹?rÄ’of=ü>^‹³Ý&^v1`[Áp!hào>ðÕ’^K%†<:œ›ù?rôìÕ¿Ägã¨éß`v£²nyív´N¼£Ž-£€ÌÛö€VãÌEèŸCû§àüÍPÚqºG¦ü¸-T8é?nŠgp;“?nñ*%@‚¾æ›Mu`Åm·„cÕš Jø¡Àlo€C˜ÄCõÑê¹èBÅ•2þ”kZó-%>O‹Ã»Â;ý¡O’r½QûnÙŒÜq£‹™L˜Ê’Á”N\p¶¥ýœ+œd£¯3(Xµf®8ÑvÀ»¡¦7M‰†,ƒÊž5ÈÃø8õË¾bsyW:4Ï•¨þ††\ÙVi/x¥Šåb†cá±®%Š‹¸K?n¹@ë†`]ðRN€+=¬tÅ+­`~žµÁÍFQ;¸zÖ¬Á$…e=@˜ÎÒvˆgˆ¡ÈAƒ%ž–µ\1ñú£Ožƒ*)Ûà&Çã mŠµš«d¥A—¦øÛh÷y¹Éœ9BÞ»öÎˆ`Í+b¢©ÃÈ<(ÅéCÆ¢ X¯ÑEêP™óT@ÆŽ³¥”“˜ŽcÛŠÂèKvYÑ^¯UÔ(kÆÒf*µÖz‹ØÛ.ËÃ -`HÂÑ-nŽ™;¸•>¢ùGaÌºÇÒ·®KÝH®Œ„¬	àÌ¢€ ’¢åa­,~-6­i0|d–^@<<•”b’éi"%J%U§'¬’«†!eA4oG"D“Ój¸¥GN¥l{ÝŠ‡©jrú\_Ò?n,M£¤^vö£Ã‡Æ¨@‰/—L"¯JÝÙz¸—G—áÏvµló°c|1/ŒA˜.¹ÑH?nI¹k@F€ƒ­qS0É"6V³}wÆ—æ]«÷ðú{{$úñ;W&×^Sà´Ç'Q1pã¬±)µ»r6f«(Øƒ~ÜÒ-ƒd6©¿LÄj¤+K­¶í5rY­daŸ‚¥(ó¬²“ÐŒþËÕd€QÐ‚&Å˜Ð&KÕ¶ÓÅ%™z…¤Œ5ôFî–äÏyïåœ@ùNsÕ;Z­à–+ƒß„Eá•†=z?0ÐF©Æ;IÙR+¿°(ŒØéÌZÑó¦ßK*Ã\ËÜÑ‹ ˆöÖp‡f»k&ò›CÁo4›},÷¤8œqp¨gôêQ.qXRÐcim¨ZÕµaEZØe2áf?rqÁ…Xà™B˜ÜsRî–££-‘ÝtX‡ªµÒ¡SzUŒPÑ-¹BEÙÔ^tÑ‚&3KÑ¤¹é|a‡:b¤o¹á2èuÝñ²ûëÄÙÕ³º|yå†°„Ùüj¡~2ËcO+SEViÉäÆvÁ”JsuV(0"HÉË˜ñšhRa5N?røbrºØ´ŒÑJ)ƒK`0—o¡ï&ìé ÚŒ¥åP$éÃ§UL4%#@‚hÔB°î"Bq#H¯1‰wì‰‰š`ç…Œ(o	éí?nu+µÍÐÂžThQF¡bqM.‡ìügNX¬HŒÿ€øÞÎ˜ÁÈª$È+˜X#C£ "Èð„¬ØWïâ0G`ôÅÒ€È…D"Ä›½§º×w#ÕH>€ç`®e¼Ëœ?rôH*ÿÆ¶c ÿ¨Ml%.?n,gD*T,%_Ý8«¢êï\CfÍ]‡Æµ$Ù„”ÒÂ6Ò?nÅ$|êHY‘* ðZ§ŒŠ»_Ei³ÍªŒú}?n??>û(¼æ6>î).»vÔïó›!˜°†ok°Ú+‰84Þ=â—î6®æó]pÏR÷Ð¬?0ô#J¬a^=h¢é‰IÅ{âiˆEÎ¼pãï’?0bGø“t30Ï—C%70$‹ïÎÃÀ‰|ã??‘…ürª2$…Â•¦`.ar3Ð…E©XÁø§ñé 0`7n*ÿÉØëMc³eÐÒZ’5L	«gën4??PÃ8£–WmqÛˆ[eEwOó=’ÏGŸÆcîšÚ(J¢Ôo…Î'Ôæ	Òh	Š??Tò’ÕÜil£{´a®öÃvý´÷ÿø:_5 DHIYBÚIRsA„`Ås%:5€Lù?r_]S˜~	ñü{NÓŸØ„??B|¿‹¯Æ¾zÄÄNá©4Š¤˜0Š!´ B©çh(_ ž	pG´ØW5î`uC°b+	´((**¤ÜV6[·¥§:qâß´Ã-óM?r@ê"	p\ø¦ðöödñDÕØ)Å¤*ÒÕE·ø®ŠÑ;„N€ 18"·ÄŽ{ÆÊœÖéœò­Q“ÅJ>Ø°“%|­Ùê)ÔC±Ž¬=ð8,†Ë£{mÚÏ>ílE8¯Y€‡°¤	Ë*Hô¸D"Šj?r®…ùh?nKŽ20?rŒ¾Xe˜“;&\1Ì—1 õ°$SH¼šßù5C‘Gâ=gåƒN¨ øˆž&E‹”¦z°£˜¥#Æ¤ýr0„C}úÃr“ô_CÊÊu#bhQ™ˆgvþL;º#:±>¦é|tÊžº—Æ8@É¥\«œòi‰Dë?0S÷’ðQÙC–¥JÀoïFÇ!y’a5]YRµH°Ð´éÌ£ÜÔ3oŒW’(qIúá‰„X66ß‚ØkiOq!°N¦9,¥ÏcêÞ5Õwaw¦…(LAMjõm•oéÀ­M=´çZ”×&×Ž!IMÒ0™!A@ÆG3Tµ‰íDåÄÇ`™¤ÇrŽ‹–ÂÉ³Q…a{øX¦Õdˆ>ü\\’§:¬¦¹!Ó¹éo–¢‘»ûÑ…È„éê<Ó@¢FRYJ²’JŽ¾Ú¬EîüJÐð‡s*¢ÈY?r±=5ˆÿ³ÛdöÂ1˜°–¡q½«ÞÉ¦öI=uVþé«ï_q?r	 <¤<!L@…"ÒØurWq”M=¿ÆÂ@©A#×Üxxz-ã—ÿ^ÿ²y¾¾¹väæ5*aŸªÒ
#)"—ù*H Œ?r˜cû©!P‘IdY "	à™Éa© (2e¤€û©!H€$šZRwýÊ?rš><À™D:P«r[ LY§$ƒÛi0]ZƒR„H0d¬¬Y¶HeNÃf?nY#%„š®¿÷ÌÙö_ß»1]'|«²ÎWŽçu]¼,Aš¥OÃV$¥_eÈâ”F´¯xkßAû”f§Ë›E	b÷êU;ñ¬›PÕˆbI%b×˜h˜X™ý$ñ"X”þò£¯OÜYM(a]¸"¬¯V]XWd=·8^¦m°´E‚®ƒM‡!OõšFˆ9÷g?nEÖÌoQa¢ÉŠÔµ6*š\µöþ¿ªÅ ôD¯a½”Íuó'/Go <¯ wCé,÷9(cí!<ƒ‚¯ëK%ÔÈÑF´$ž¶»½??@¸cÜôó¼Ä{ž$˜6"öŠ	C	&à—WEorªÉPž¤ŸÑH|ÿµa~‡öA®DR,Qw¢ÊÀ¯‹4“¬Ì&2m…ÃôÝê~Þníc2¯<tô0‚…Z-Ô[y	2œSÜÀÍ@KCpñÙ8³ÍGÞ¾dÞ¤ODµ%À¤j,ŠÉ"Ì—-GbXötB 91¥jjÈ”h‰1ùý##~N¾Îáåí™ÚÍw(4w˜6µéaš–òÊ(­“oL¢œô‹öúLay:ÊÞ&ü1ÈêËGÛÇÅM\ªïßÊ†‘Ê½ß·Åçz;ô¬¹9kKH@òêVwè¡eO7Nó—KjŸ-o‚¾iô|‘7Ëìâ$ˆ°‚	@ä¹)dAWDñí<Ø&vü?r8+ÛL—G?rÊìœv˜àÀx)¦©g9˜??k­ÄÛy•\¸Ù¤¸Ñ„Œ”ÖÕˆ¨Õ´¶JpE7["¾ÝW˜‰¨ZNs•UèÌaÆS{@‘d)ñ|RŽf,IQ0*$%&å$‰¢Úë˜4‰Aq /2?nêÒAC&eý)ÂáÃ=F*Øó…7´ªÈâ6h[¢bDÀ,Å8nûø´9x<ž·çC§è”ý‹"Þª%@¤ˆ¤ŒV˜ASNvI.øtnµ–{Þm5c`Ý¶.•–p?n[hmvô©^#Ë›6¡G3H?rúÛgl"+ÌfX„´ÄWcÖWˆêáÔjÛ¬w»hÞ'Ðâä³—fsÞ-è„½‘aF5E!ñ¯?r¸?n½Ô {|'_¨÷ŠÓ&{a?nÂNÙEb8a˜¾yJ©|®‹Ìr²¨Õ5Ý‹¦$Ò	Îá«ã})¨ h#jQ+ATRNÝÉÒR—[‘Ã,70N”Ê0ú¡õÑöÍëÂä®Eguu³R·šx¶_ÎrÌÙqÕpµèëÆf«œÜQ4D¯ùß/V…­¹<_GdM½ygœCF‹çO‘p·¥'dt’‹D²·§–È«Àa†õf¢bìÊèÆ˜©Žë/Û"2+QBA‘P˜("/ÃÚ_dÐVE|8r‚ÄddDVHèÌ—]‰“y=°ÖÕä!Y€T®	{€b	ú©Ã?rº‘®í˜…Ò¤Ï|€o9{xDA!ñ¡R*N»´!ìSå¡ì?rÉª	¦F~mkör{°ÁÐâ G?n„ŒS=>ŠÒXgÝ	+Ý—#E$“†ÆÚP˜VË)ææ¥l2sÀ<ÆÄµÐkLÌ‚}ú&Ê$€Ï¾gbDuc[æÌRQªòEÒéÄÀH@ªtœD^(.4)t‘sc]¦ŒåbÏ¸úŠl?nL÷ø·¨(ž	ck30*bÞm	yÂšè×•ëc6h}™€ãjß"ŠJ‚(¨‚è\ôúë©™[x:Muëc¶[âåÉB>zd™À??ñ7ï;X1M 1Bÿ‡¨³/ø‚ø×¬•=–hf&ÙØ`•$C??&ck~ï"Øº;¡!PhˆÅ’AF@ëòw¶H*¬O$ ~­ðÃ°yu˜À-O§©î>‚	ïüµÛ>ƒ¸»ñ½ù#Èua_ÊXÖ®qAV°î>ÿ+Ìü¿œÌË®E,Dó¦9™ökª|/ÞÝ:f}“D+6íäV)0çœ&N?n]Y·\]!ššK#9°Ù«Œœn›xN!Ã¡*¦1šÊój¬PRi™‰™\VÎ³-ÇZÄE±ZmAÈ™›’‚Üu†í¶[¤*¥ÕÒiÕ¤pB¥´Ådm¨²$IX*„ýp!¾X’z¤ÊKpavÍñrëlÒ«E jÐ;a4ë1nG˜nÓ’ˆ …œR&êbˆÄr–[L¹‡Bñ¥é»$Õà+iPå†05ª¤·z4db‹ ·)¦c©¬ÔÓ	¡tWnŸ&û»sÎb"Vë¤ÝPÀEf=	Ð‹ûÈ¶5Š${Œw¤·úùè:?rrH	½™’ÈDzâP`w$nÄFaÓ•„ûô@ô²ÿ??+¢!úƒ‡å|«Î˜úFáˆf³Ì¸”ÔŽpØÐØŸ»R‹ñÁTöàµƒóö{›€~(ø‹K°fR±’	Ic$À¿88žÿÅ4"}¶Cð$`bÈ(~…€ TžL„ÐÌŒ‘d63lÊY$¬‘dÚCZ›¡ìŠ³C?nÂŽ'«wIòÒÉÙ„ÜlÍ©²E’€?0ˆAÐÁŸ«%!Uè1÷°½Yf$@X\‹H@’8þž¨ð§HÚ:0¶èo¤Âà2‰¤??…@©ó?n“Š,¼FúˆW??—¸×qÇ$¸æQòRAòµ=ûæmvŽo,Ôj9…ÚJ('…Í†8á{´x²ß ™Àl]¡‰»v‰rñŒC†‡j¥ ßx7¨@C3x5o	¼B==L?0H@ÏE=2‰óúy??ÚYì5Ä¥B@=[WÉK–ÊO&QÓHåYRµ~õ¨Ã{ÝF÷ù?n€(‚å‰´³AÑ7(t/˜°\ÍIG—¼‹w]8AH‘d@d‘D‘"Á$‘x:ó"‡såíí<ÀhyS3“Ä¦D??{äæÏ1Ln%Þ*’¥$ƒøm¬Ú¡æ¯€ó<Žçe×ôÙ¨tûj££°%ãHTü¡¨LrÒÀ@?ráÁƒ}œ!ðÜáÜ	<e‡CY2&t±9Õ‘‘ñ„D€¡4þi>[dƒ;’Q‹ØÞ=Pò~™Eª0˜0WU¼ÌÞ‚qFø1×¬¸ŽÑqjvxõñ˜Å<ølD†ù¢qŽjg&½‰¾éñU«yx8’ÅUBAŠ6TM*R8»·ø×hªm??BÉ ‡£=¾kVl>ó~è†Pñû¹ýs?nïãòÑ¼iP0ŠÊµÊs.FÚ%(¤«—Z²$ª[D…½ì0IÍ«–Û\æv¤ühCü/¸¥ð÷T}º›22SL.žÊ}¿è£ýüúéÑ |áõÂ³ûÖCò1Ý§©–Õ˜Š s³±Ô(-)´MW®0Œ$'  aAB‡ž®¢?rtÕ`?0ÆÀ»ºjm$„²Z-|2F!Ù(âtF·¦~n4<kŸÛüÝz§,ææ{qÅïz&Ê¯4ûÓòc¦‡?rÅù‚(û?n¨7ÀnESìS?nî8Cš•¢	­–ž<Ãæ‹‚Xçç‰ú‰?r¥U;€iâ”ûá#Âšø".¾¶%¿8¨îdÂÍ´!Ä1\½£~‚Ðs??l¾5Ï­8€ÄááIxæ?rW·piE7;ë’—›ìNîK8‹ihTx“[üÝûì¦êÅD»šú|jÅ[F.{!LÇÛ/¥©VÔ//…?n›c±˜ñÆ?n/l·˜´‡€Û²”lcBí½	©Èå¬‰)^qGŠä¨—:ªébÙŸA]Wžº³+¤Z]6….S…h*áU$¢e—²òœ´o¸¨&VIédÖ¨?rGëàÙKhX`E(èY%ß?0-Óªç'bµÞ§%7¬?0ï‰#UoÚLé|Ò$_)ú©êöúÁ™ðkö‹rY«E" HB$°Aúý”ƒT‹˜ÑDÜ2??¶Ø}ÔÒêÐ‚¤íî8ÐTÔ:ÙÕÛÖè!TÎ‹!]?r-†Aøñé†Ùcdæ0„Ä±B£>ƒ¨K‡ ÊÆjú:à:ŽÉ‚$°ËŠSîPý±ÄÓ·j`†_£S3úû³€ä¯\h)w‘c·çÕa«Húpæ=¬âîË˜I·¬ÆËEîÈÝ{}”??AØcCï!“¦‹¤îê­¹$yÂ;¯áˆûˆI!”]`ònùêV\8»Lìæ!Gy`QwÄUÛô‚55SÔ÷×<9HWzƒMå#NRÅ¤÷b–b	c{'@G‰›æe‘Õèì"¸pËÀ÷¡.ÀæŽaÛÕGó(é5c~íËu*X€?rb?r™+c%Rá¤d`d”Ä”kMcº?0v!ýàŸWÁÍPØÛ÷.‰??°ƒ”çÞÜ*Œ1rdJ[bÑ6tÀ½É£à7Î@ìÇ ¹p8~^Þ@±®•Ô.{¤Aý˜¨Å_íŽÏwÂ:äv«Îâ‚@¼ž£".²È• Å@ ¡ l£šŒ$`#‚–ÓUÚHrÃGÀ1wtìå*Ç™FjÐØ…ZÒ¬EEF`¥Ÿ(ö}?nû”'æH8Þ‡æ!rìŠS4:t q”üZÜû?rŠ<,±u©¤eA“'ØÑ‡˜”L’.Á¿a˜LµXªý+YC	?rˆó=l£Œº„œ@G˜Ëå±àiÅËQÖ{Dîiè­™ñ¤ÅeJWy—Ô²–±±š$g‡ÂL—ëBIAü]çÇé›T¡ÀY){ùÞÒD×;ƒëÜ ªæÌ¦ÉŽ=E'}Ë›`*"Ž&E”=Í˜0@'ëê9{w6ú_Ú1ãu2ªíH2ºåø™ý0é‡‚Ç"øÄ‘=KÒÒ<û>õ»ÃßËïÚ×[°ô‹¢–‹ðqö&ˆS€uÙ3×©p,¸ùûL“™9[Þxû+bÅùX†"F)ô.¹3÷Â%º{ç²TÈoªÓUdV	QRtMeVBR‹K€Ñ²ÃhFÐrÈäp>iÓÎkåÎŠ35É¸=„$GsÕ€g!tÞì	@·›w Yu„Û HGë?r¥´:Ñ54í££eÎðîz¡óë??³L‡ED´]ˆØ)ß¼¿OUCFâýÙæjÔôj‡Ÿñ‡„ÕÌùcQ$J¾Ÿg–ÂyG|L ûòNÓ!NvW$âéá`0‡?rÞ%”‰H]¥  JÈ??í
#_@æ?nˆ”›S¨ÙÅ89k7ÎêT‹1±RvU5ibÚ]"¤‚‡GlìÓa¥îŸý¨!ji¾ù4ØäñÏ0ƒJLñ†¼§Ñë÷tø´J"10ãà×Ô1<íiˆlR¢¥ VÑîVðÈˆ1ê èÕå"£¸«^åEA¥FÉ±Øsi¡»%ËB1 ŒQ@?râÆÝ50dAd§°1è–FIÂjd*„S+Æ±C_^ÿy:;„azó¹`H†}ùb×Ìþ"×ÖâþBÖêú)§J“i<áZa:I+²64­ Y£,*…­¢ƒ[^DtRTj•eï‡ˆáýÍ³‚Ê©Q%1²<b3¥B¼ÿPë­÷t¾¶BÍ*I9HGMŒÚ¢`KK•Nyy\®Šµ‘}Ö‘R&Ð9Ê+L\Zr?n´`H?0¸6	“`‘Ia“%…ÐžVêÖè{0ÖHiÝþ†áÀ¤Xp?r‚2¤€ pÅ&Óc?0qe$¦£$Y1¨,º+B¬XˆïÃÙùY Ï§˜¬ð{S!ñ‡k}‰£ºJ`åÔ/@ã+P6`Œ6d"È~Î²`¢£fµê:t'«döDñdG7RGÅÓ¶1ðÂ×¢J–0O†ÒƒõpyI¶ŸÕ'Ã	‡ë\Õ’£be„Á&fA]>ª¨ÄµûäØDR$Tçj¸Á‹ÆÍìß´Š2Ð9ÄÔö%óN”ib=pr‚tÄp –Šôž*¼ý§nŒŒªv‰$ñ´¨ÇX›Ü0	ŠüEÃ¥Âé &ðü|xñ³áµ»—v7_(šKn¹†Ö11G¹}§“„»\õ«û¨¸zbtÄHbÑ‹ò""¥©•òlL07P?rÙhjÛ%b–ÕC£3uª>’KŽ˜¼„…’+Z_û\!#‰Ï?0v£A6„šd¨V¤	«dRdiÙÄ?r¢$4ZQ”PŒd°c&ŒŽ©»¸2lŒ±eIË8È?0\’&V˜À”LØi1Œ@‘A&ƒtFé	8£Ÿå7¦ôètlðòõym¯Î`^÷³…S9FëàìI½JNY—‹Û¾	¨ŠT$Ã†¿§ £ú²×ŒïËgCïÝ˜C÷Íj$'RH’Fõ³‚©‚õ*.’°?n¹±¼‘UÐ0Í*ÀÑõíÏVgxÍÜSIŠ¸­‚ÚÈâÌAkOzkHpMi†!ÅzæLPbÐ“ûQ_ ¾‰\_Köðpºq?nš¹n`D9â‚ø	“ô¹ÎZ¤“¢WŠP·Õ|O~…Àz¢2) Â?nBÈˆM?nšÕ÷ IyÓDµ6LEKSÄñùù{£º\êÅÃl;áað%µ‰"eZq–d(È?r[@Pg~Î¼‰?nñ†m&€ÖmÐÃNG"C$eE@#`*B$!ªÈ¡/ŠCIrEecÙ²ƒ"3>)”–:²§ÎfÁqÎ^I”‘NJ—?n0¢áÁ¼Ø(szž2 n™äâ…0A­Qr£¬°aIrˆËÃÝð>-§;`óvxÊ>Ù¤LâÓÕÆHšñÔpMŽÞ-0Jj AÔÄ´+™äè±ðŽl±é*z4ÏÊÅ÷ÓÙy‰%^>,)5ÒëÑŠKÝ¥Ñ‡ÈÄaŽÙAÍqEIÕ†tÿ¨)¨¼HƒåMµì›Ü¥Qô²š5¸5/†ˆG,ÊEˆ†ôÍnËX= XY¨ÂåØ°æ:®Á.òG˜(x–bÐq}~ÿøùTQŠ‘„€Èª¤@AQ€Â*1<ï±^{¼Æ½o–p÷}£\º¢Ž|	† ]#zü % ÒûUý†üÉ8ÍXO?rŒ™„íÃ­C ™&e¹yçÒ=¹ ?r‡j1 ²!¼Õz"¼¤VD¼`Ób`??¯»Œa{½qÀÁ0Ÿ/°ž`Š'²Ò*¼??9–Ê°M<lùM²DzrN(hÚPBÒFÉÔà¡´6t4>évIÛòO	z´$¯¢š€5ÑÉP6»€É‡EÝa!¦ÀÂ—ã *Ô#æÍ¦Û­\"ÉŠÛ]9ãŸ!-œ0€í¡¬8QY×YÀs´­ƒ*ÅiÁaOšø"sÄ¿FxEK“æÃÞ'y&·	zÎ??l™À¥?n—e$Œ$462VBV¤’úH‘d¶X?n?nÏ±¢ŒO}	CþÔ«’j”"£""*ÃÖs—­é¬Äà„sT?n=qÀíG1‘¶‰ÿ”£Ÿ‰sñ˜†Áv7ÒÁå4TdB0Qþ€„Ð]ùð?rsÄ(&æqãPC¨ØÙÔRVÊž#?0ùúøÔr©2ÒaçÍZ`pJã §u‡ˆÃÇÙ!´lDGÐª¥ Ø¼Š‚÷Á™™Ð4Ù-’žhas&7ÜRj1ÌUè@#J?0þßUNƒ#®Á$ÙvÀ3B$bÕó·ÓË†;biù¶o?ræ2h"|£5^ýd§™¹¨4C™ea÷Ð7„“wñQaZÎÐCóNQ2º{é²v7Í¬#|O;´yÔ8=ŒXßÛBâ§Ò l£æºØV¦8­LcÖêÊÅ×ÅÁÈ½ä,TkÂqÄIÅ¤áÌ7ˆÈ¶”0W?0µí˜´J€Y2(36ÑJ‡¹8ÁEõªÂ‘¬qË‚„HR<õãM?rv4hË:êÙ~¯µ9:ŠPñ…®wûSDÝ†Á¦œ‘6ÜJaZþÉ·ÿ`ƒ_WýcúÉ??‡yÃÛA¥íÈÒ˜Ðk8ÖåF˜|	Î)ëÈoÛñÛV\¬u‹Ðtå|§_\éT®¹S³j¿>×¬š”Ìéº[k[x›.PÖQU§¼”¶Ø™B"YµLÔçÄÛ¢#cÌ@°µî“Zdý’Âè9œ±Gm†·p¼qç|†ØÝÊ®¬zì/Y\"E¬ÎÁ³L<D	P‡–‡ÍsgzqÌÂD@={V´þC±::’‚Šª??Ã¬.ÒgËØE“Ò3Lò0úñ¦¶ˆE?nXý‚˜[ŒÆë×Ø9³¥°c¦°©Š[-Já1*.í\ãfj¥ãTƒKë`\Ûàvâ§1Nî;¶?n†ëä0ãÇÞ:ÐÄ?r±Pò²I0h½R‚²ÍJŽ;¥êµY»ž†Xªì.Ý{˜= KüÁf¬°{³HÜƒ~ð{h@ù¢"È¦oËÚg”±´ÛÇGÝ³Öœ¢ðëÉNÕ$3¨zISU“ãîUáÕFr^Í•ôWˆjÄ+!²~¶'ÇRïÃO¥&ëQ¨Ô/oÛêîðªswbƒ}9<™	~/GE²Oòßƒçñ}®H?rQG„%û©Bô¥™bÈ 1Š@`ÄIGY-¡gâÀFI=’–B'ŠÏM˜?0«+%+é@ €cô`P)JQH(	$‹>ÞçRžßnVÒ‹#¦ë	W|š½tÂ™•¥=ìcU>ªL´*ÄOà¥ï#÷=T¯£µ7ó¼)Q4 ØñTïfv’øº5—SU	NŒÙR?râhF£`%w[déQÄÆë¢÷Ü¤aHã,-Sav¹a $EÕœä×wì zÑO…>c3]\>úHQ*gIC|¢F¤kÏ¶Sçá–Âñ/ÞÂ«R‡kž\^J¨D#^Y,7Þ¾ÈÅZðDE­brZ^Ò±ø?0Ãà O˜¨Wñî ?0?nµ†“$‡nÞÙ$’÷:¡‚Ÿ¶†‡™£'pÐ÷ò:¬ýÄ=<o6ÃÚy§µƒPóîU[w¸!þ£™¿w#/„Y¤6˜òœVt¢òÌÓ?0ô°\Z"Šs–Ikòéá >ªHAF#zdÏÛ1e±o"k¶¦Ž·À??þÔ<Ølª€¸¯kÜÙx1HõÐ÷ÞÐCv°â%Y¡‘‰šf‚ÖR-'ÙòÂ70¤èä/Þ(”Š¬Íû7í^ÃÏ<Žab€|ûŸ+?0c )ÇóÄ'.Ij:³¹<3a€w»‹¶0ÙÎÔ&H‡lÀî¼2Epi5uÄ£ÍÂ²W‹Ç±9‹Ö±ù-s›Ê¾X‹ƒ}äªV¡P±‹?r¥´°Qc-­_æ)†Z­¨©YD°em¶?nU‚¬-5–	‹eI!TÈTJ‹!]Z.£^ýïE¯†„ç§îÈÈ'qä|pm_–ù,áa×àÕ’QíÏ•Èw!:ÐÖqõƒú¬Y‚\¦EŒ”{tt„"AÐ1…‘Ì¨cTîe*`ˆ7Š£žAHsÇmK™ŒÚ9)² ÍÈ©Þ%.ÍÄC˜ðzø??dæAÚqôo{Õ9p·?06¼‘Àåˆ±æRòçù1HˆÐ3I4%CÍGC4Ñ‚‹  kÏS#€²I†ÔXw€6Î`¡a Œ„ w9I,AŠYh,*	¨2)€µd'–§`ûä„dŒ$Ícªy'}ŠÄä}åÖ¨xÄ?nÇtv’Õ(¨<ÒI,r‡´74ªþõO·®¿‹›òÛu¬žÞP¥šÝš61C¹Ó³:êoêÕb.µÉÞÒ;#º0^v}csk²\¹ÅvÑC.« T¤b<€RŠ@©‹µ–ïŸhÐÌý#l«I¨iM|’X˜T1oG„hPGˆR¢äÁ\á¨Ï[_IÈ??9 óª™,²fùmÂ@È¯pÉ–jÌÊ4Ör2»n¢8¾Ì	’ShÍQ#”´{´¥¹›¢X‰AbÊ‹‘°mipØ/‘€sS1šƒµ‚û"q¼¦”XiäÍÌD¦ˆ>Â¢"A§EDDmDn·L?ra³-C3!JSK.²vÀ?0á¥dÁsÀ ôUÍBÁØ‡$‡ç_š¤&‹*ÖÜ…¿$Sdg¾(¬8´’Nq¿e06ë·ÚZ`öñé˜‡ûì/¾þî›fÍ”ÙŽ’q¾‹I)IÙµ. ÁM µZ;ÕK“c#iŒYþ‡Z0lT‰r£ËË`1â4½ƒŠÕ”7«6çÓÆŽ	UPeË):ª˜#DGÉù<ÃKL„ÄÊA$ÂÔ°”,+øHsï0ÜÒaàA•*â•Ä²J)ÜQ?nÈ:ùy?0ë}¤Åç*“‹hr SaóÜup’Ëª?08£‹æôƒ<)‘Ô(âÐdÞ8„©‡¹HÜ™¸É˜W,;C`‚•Nû¶RÒ·»×=*ÙqEÍqL’¥É¸r“åFEà `ltß›†¥ºi¡\a•
#çeQâ·˜A‹3â)«¯†A_’W?rÈË©‘mºŽQ›«é+”Ì)J/š)ï&v µ!å¾¡Ö°Ë	B·.8Ï‘Ç±»½å˜T‰‚ÍJÇ{:ú+Lyep[ž¬?rðQ^¶Jâ”è°?r¦°Ö™)±zk¸p˜á—rÄÁ‰×æÚSîHv5HÈGýzÉb”¨µžÕHhºóÆ^²X=>\ÃF˜©Ý’ŠâUõ\ˆÈ/mØ‰¨C÷å6†«©ÔóD€«4©=	)#~™ßºdÜUÉ	Él‡)D)Œ[ F¡³NX™bygpP£4L*\2ü)]Å;XAbz ¾î¤˜(éš—dAóÑ©ÌˆÂ$†(ŠÈ(°")é?0¶â‡¦F¤8d|'ÉÏ–©Ç™!ÀrJÂj”’IéôÉ,[—n7èè"ãÑÔð¢iˆ[E„JKóãäTÊé« dKx•­¨?n1+sÄG.)È?r&Ò­ã·„aµ(Œ%+(THÈ@J™¿ÃþßÿïñÿÏèõÿ›³ÿ_»û??Ç7þ9Px·ÝËŠõ1ÁöyåpO<> 3Dû<¶]°_»oÀëÍ`ú… {º{N9mj“ñÍEÏ¤¸Cy%|F.ù×7¤Ý*J¯Éë(ÔÄÎupÝc9¦?0{æõ¬Ÿû3Å§0gTÒÔ„d€'O“JCm*,ßßßp²©‘³ûØÊ}Á`±h£·™ ˜êÉÚ‹H»™Qõ+zGTŠU‚´(0” Ð±JQQŒ²‡””a”FQ	 ·Ç;z}F³vËƒhˆïÈŽÕ¯KÏ&yÂÁQÁF.B'YÑšFcÌÉ¿µC[©û9Q-ªš"µ±ÇÞ/ª‚ñÀí'p_öûSQµi|ûÎ„¬E•R²øôhtŒ¿ëhïCŽÀhñ|_Œ|·±3×èËæ2Î§SiÔŸÉIÌL1òµÙ  ¿ÚÀ*À¢è?0ôXdN:úc€oäsâÎÐÎQÝÆÝl@gÕWö¾C??døüÞ¸\ðesÙB3R"6qÜ”ÝéÇ*¼õÃ‡ZJöú'&BË-–@£‘HŒt©Y‚}:…ÕïØç‹Þr¢ spÈeBÄÞ]•k0Ä`Î…ÀuZëa£ÝP´]*Ž:ä\ïˆMYše.M±š¤Ä´}ììa›ÛÓŒÎpfå?nF?n"®yæ/=k:£mc	1¨XwhÎ¸½™ÏBÕæ°w™ÖÞõ¹Ý´&^ij´]‰TÃ&D<é–,„'[;(Ù[Î0¢„-„èÔ¥¤.mú°^LÄ¨Ñ™%sÛ]6'Îµ½/f?0X2# *!G-‰F•E®õœa¯vø¾#ËmÇÄa8ÛæÍ®R¾UÝTQuæ¨†f¼ßšåqÖ×¹4º©Â)Ì‚@•›ªlá Ì²ÌÐÚ—(	E9¦a?n)¢Y)QTTDŠŠ¢2ï&#¨Zˆ²:¥\kh2ð:;tàí»Nb+?nºù’£è½»=Æ®™¥±{xM`†Âf‘€é$1ÛW0®êV¯v½c‘tkÖm+@ÖÌÈŠ”¥»ïqñ©´ÙSGãÂ²LI¼H…¡TÅÙ±K1wRÓ†,HA³~ºU°+‚ÈvÈŠ$‰pÅ¥³©ˆS?nÝñÀó,¡s?r60}rÖÍwÎCIsÂï™¨².¶\ñ(°Ê‹FO€Ä-Ê@yTœñ_Dê±ÝG³À?r	ÚzÊ—-ïuÅ‘Ð1W·Seï¶^9ø^z'¼÷??È^ž¾5°£³ôµ)non1-¶ ±tØºZ!‹¦µ×º®tÊo·¨Åæ,Õª‡Xo„4WY+NL^Ž\ÇƒRm$(v-ÐØc§pZÏ'rÜÔ25¤šhY‰?03(Å‰£u2#afŠ­¥P#hÁFÄêŒU»L­Öò0RlÕÜ¾õóK„ïQ“éÚ(®w†ûÞ¸Üâ%Ý@VÙã„é:¨à"1‚›Mº[`-"[‚V?00]ˆë‘‘¾ÓŽn¿<;‚ÂÁz¤†¬ì™RîZÅ¬%TQ‚h”$¿óë2¼H(ÆK8”hjÉ¤®³ã®÷+äiÎËSã\¨¬·A¦Ò‰­Ãótgæd¸g¯gÉøOt„W¢,g`ƒXÒ&Øûnï®è"ÑiE]?r…òY­n‡%%–w‰3L£Ñ¼›¿®ÆQË¨?0Üû}å§Š0×%¢˜‹"qÇ½§~ø•×$ËHgàµ²¶H™œDäLVÌec¢l /|@u·5Ž¸—#ÝV®)sH¾y ]3Í8j{1>ÉçNÿMÇ'&¨óòšÇËãP·[rýo’×°ˆpí	?0N}‘	ÜnP5õ±¹«8­÷rhtŸªç6O:Ržà‹ÌŠ&“2D×Jj/ØRÖ×ÏÏËÑãÏ^Ž˜"¦ù)Ó£ŽÈ´¶Ø!ÕÂ,êÔ¹”H,DEzì×0º”q‚vÀ¢žŒª#zZƒÊ¥t²Z‰ÃÇv}Ý¥Ê(¹Ïq¿æ­„“o âéèˆ€¶6€2ß_°PJ?0tWBƒ?r*Áî8i%+ä5yE'0²=ï€r9œ6¹…A.uÈåñœºnÚ	V§%;´Ä"ÉÈÉ!k3?n¦ž—W‹¢­ÕG¢?0OÑ¡# ñ%Äìç>	1’ƒÀ¤aáM§š%â?n”/ùC²{Í}V¼:üÐþ2s?nD2îì?0SÆª	î!½c‰ïyf°‰YH¤´6·£)ã­Í‘Œê$W»˜T ÇÅ‚5ê(…¬É™T-‚“y`x–Êº¶:ôîÉ×™X†Ó{xï¥wy±*nFH'Î‰j«§šÃaÉ_p-ð$?0“ ?0ë ˆ'??•°0°mcy££[sFÆ‘`	†$Ead’ç³¯l6 %^Y	‚8ÊB^lÄ†	¼¦‰¡ºË©++ÆnMëpëw2¬Ùh¥«DiªºNM[Ž¨âáhtlÉ&a ŠËmeJÅ?nŒfI.cŠ,ré5«§2ÇV1Hè´EÝ›mh†°?r&01†3bKR@r‘§b–0t*!Ë%?rˆ¦ÒNª&bÙ¨ËYH¥l–ãÈ¥ŸqhGÍÓx_µ—ì9Rvû:Ø3l,R·VDiž®Y:à¿ô~ë'xøÁ)xê¹a÷½Þ"ýè»°ìÈ_è}Fkç‚1!'Ì(¡ÄÖh"®BÅŸ??ëÿ)Ûêîx#;±êDöÿœh7ö tÆ@a‘W¬á«>V4ÍZ^°÷9õ?n”ØàC©AìN*ÀjZÃŒ¬o´U².aÚ 0¸^R.Ã^ÀwÔMüã×EêõÐ gb³Ë?0ñêzóé: i¢Ž?raê?nX\j’À¸½£@Üû2EÈHI$‰:\6^ÏÇsc…*•êÆ…ë±ÅeAWÈ_6„!-H’2mBAìò©[øê T)žŠ6í•ÄDãˆÔ:®”Ø$cßHŸ?r¼Å‚'šË(Hr‡ rpÆA”±¡F‰E‚Åýº}¢Cå\]@Áãr9Cß%ÐÑãçâèh7)[·ú%®y,¼;ÐtF¤Ž@<„½ª¨î4Å= Íƒå<’-Úcº?rzïUè½>þ6ïÐ½gcÎlìiêAÓ,%”„+•µ«ú’,¸½$Š=˜Sæ¨C(Ò¸Ô\•[å”kty™¡Ûm1‰Þ8†Ü²»½¦™1‚H›7x`µQdÍ‹M¤"npHûYÑË­˜Ö¢ÿVfnE?rl(ú€µ S÷>ÿáâwM¿ˆ£è*‘Ì™÷íâØdOué¬Fp*7n¦Ú]^Lo;+¢½eÝ~x ¬üp•)˜Qm>‘(€%ä¹íA²Ò PHZÓ`\„H¸rÕsPdP2”ì¡!BktÅi«žr¾ê&Æµ#ˆioÖ?0ºì·)ú‰Pý±5óŠÕAúaP	qþNõo^¾<ŒXÁ"›¸è¿nˆSßÅWt	#°ŒL´JÈQ'6¡W?rx®Hc-E’9QKCëd€dažž¿ò}ÐÓ¹X§BÔìóAÒ66Æ‡8~Ÿ²úï²}3ßJf¼¹‰§È~FÍëÓúgO:õ]ago*ÊÖ"(â†wßÃÑ¸û¢!"Œ?n @!è )‰;2?n<<LÁ¢Q}H}'g¾Ñ0dß{Ù0‚{Ð?0>}ì’È‰´áæ)?0¯Qº÷@ùµdpç€›bÉE„„ŠŒ€²$PIQÅQýÛ­Û¹-¿‡W™4þN£±¯?0[:3ûdêÝ^™+(%©vúóþeE§ZÚnÔ«à†„_ÂI…²ðŠÇ¥+“†2bÀV°;ßá¦Y2´˜œV€=@q±	ÉÉ%PšàJ0Ø3~ËëÙS½c˜÷ðàÃÈÜ²rÇB$IM 0ukâá°¬NTŸ†ég!»=¹óç¬ÀÄŠûÊbó9Œ,†zºz¥2Î¼!ÄÚušlñ)©¤ñb+ ÈÈœðj&Ý›ßÝ?0rá†âBjY>òOá¤R&Z‚f_a:²öÒÍŒ÷9üw<òeÛ+€\'öœ÷Ž€ë3JÃó}ãvà+Q¹9 ¡ÐGˆÓÍ=xbbê÷ýÿ¡ÍÕçªíé…;`TzYóÃ×‡pW_šŸt3«µàÊ?nþðZÃåJpR{®tÕÏîaÇ”Å)ù Òò7«·ô2‚ePÃ¸u_„z´Ûuß?0¦yý/QrhÞÉ§­B3bÎ/Œ-l\›k@kÚz<®óØKYßÞ5»H–+µŠm¤ÏÀULÈˆP¿ƒ,¿:€zeçq‚”Ï9P¢ªÂ@eå:RH,º§ÍÜo?n¡]€I«r„”‰¬X¢=hvAÚß½ˆç(F¤PGµ6Ž×ñ³VJøÛ’„¡gröq?n¿çý^ŠïåŸ«ÉdÞ‰=ÿ{½þœqá2	=??„)«b¬Âñ1MŒ;<£êý?rbßnŸ§åZþ¶X~Ë£FÄæÃ¬ÿ2~êc‡•üýT#~˜ëÛêé<—çBbùüí”Ú$*û'dû??Wë}gÀšO†Îh/áÇšoY÷2¶p˜(sÖšÔÝ^),wûvÇ_m1g?0õdÂ.–)mh[Ó(¢:WýªLš&_0Ö^¬$·gÒó,íKOãU.Óf¶@Z»Cç1¡@Ð¼µq¶D	}ÒÀ×Ìkhmžèú²bö`fRVÛØÌÂ²?r³ÍÁ1Múïôºë¿Gï
#þÿWöŸüùAPCþÚÿl6‚’Á-AÿØ¡q´UÿøEÊ ¥Ìa2Ê‰ƒ_Þ§	süÖ÷BðŸßÿ§Äg÷ÿüÀ(8¹ÿÒH¦~‰%+»CöŠšÃýÅ0‡è¡`Ä0¹J‘Áº£ÌQÿü]ÉáBC£ÝÓÜ

