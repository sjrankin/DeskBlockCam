//
//  ShapeManagers.swift
//  BlockCam
//
//  Created by Stuart Rankin on 2/18/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import AppKit

/// Manages shapes and character sets.
class ShapeManager
{
    /// Shapes in categories. This structure is used in multiple places to present shapes in the various categories.
    public static let Categories =
        [
            ShapeCategory(Name: "Standard", Shapes: [Shapes.Blocks.rawValue, Shapes.Spheres.rawValue, Shapes.Cones.rawValue,
                                                     Shapes.Rings.rawValue, Shapes.Tubes.rawValue, Shapes.Cylinders.rawValue,
                                                     Shapes.Pyramids.rawValue, Shapes.Capsules.rawValue]),
            ShapeCategory(Name: "Non-Standard", Shapes: [Shapes.Triangles.rawValue, Shapes.Polygons.rawValue,
                                                         Shapes.Stars.rawValue, Shapes.Diamonds.rawValue,
                                                         Shapes.Ovals.rawValue, Shapes.Characters.rawValue,
                                                         Shapes.Lines.rawValue]),
            ShapeCategory(Name: "2D Shapes", Shapes: [Shapes.Squares.rawValue, Shapes.Rectangles.rawValue,
                                                      Shapes.Circles.rawValue, Shapes.Triangles2D.rawValue,
                                                      Shapes.Oval2D.rawValue, Shapes.Diamond2D.rawValue,
                                                      Shapes.Polygons2D.rawValue, Shapes.Stars2D.rawValue]),
            ShapeCategory(Name: "Combined", Shapes: [Shapes.CappedLines.rawValue, 
                                                     Shapes.PerpendicularSquares.rawValue, Shapes.PerpendicularCircles.rawValue,
                                                     Shapes.ThreeTriangles.rawValue,
                                                     Shapes.ComponentVariable.rawValue, Shapes.RadiatingLines.rawValue,
                                                     Shapes.BlockBases.rawValue, Shapes.SphereBases.rawValue]),
            ShapeCategory(Name: "Complex", Shapes: [Shapes.HueTriangles.rawValue]),
            ShapeCategory(Name: "Dynamic", Shapes: [Shapes.Particles.rawValue])
    ]
    
    /// Map between character lists and the font to use to display the characters.
    public static let FontMap: [CharacterLists: String] =
        [
            .Arrows: "NotoSansSymbols2-Regular",
            .BoxSymbols: "NotoSans-Bold",
            .Flowers: "NotoSansSymbols2-Regular",
            .Bodoni: "BodoniOrnamentsITCTT",
            .Ornamental: "NotoSansSymbols2-Regular",
            .Things: "NotoSansSymbols2-Regular",
            .Computers: "NotoSansSymbols2-Regular",
            .Hiragana: "HiraginoSans-W6",
            .Katakana: "HiraginoSans-W6",
            .KyoikuKanji: "HiraginoSans-W6",
            .Hangul: "NotoSansCJKkr-Black",
            .Greek: "Times-Bold",
            .Cyrillic: "Times-Bold",
            .Emoji: "NotoEmoji",
            .Latin: "NotoSans-Bold",
            .Punctuation: "NotoSans-Bold",
            .SmallGeometry: "NotoSansSymbols2-Regular",
            .Snowflakes: "NotoSansSymbols2-Regular",
            .Stars: "NotoSansSymbols2-Regular",
    ]
    
    /// Map betwen the `CharacterSets` enum and the `CharacterLists` enum.
    public static let CharacterSetMap: [CharacterSets: CharacterLists] =
        [
            .Arrows: .Arrows,
            .Bodoni: .Bodoni,
            .BoxSymbols: .BoxSymbols,
            .Computers: .Computers,
            .Cyrillic: .Cyrillic,
            .Emoji: .Emoji,
            .Flowers: .Flowers,
            .Greek: .Greek,
            .Hangul: .Hangul,
            .Hiragana: .Hiragana,
            .Katakana: .Katakana,
            .KyoikuKanji: .KyoikuKanji,
            .Latin: .Latin,
            .Ornamental: .Ornamental,
            .Punctuation: .Punctuation,
            .SmallGeometry: .SmallGeometry,
            .Snowflakes: .Snowflakes,
            .Stars: .Stars,
            .Things: .Things
    ]
    
    /// Return information for a given character set.
    /// - Parameter For: The character set whose information will be returned.
    /// - Returns: Tuple with `Characters` containing the set of characters to use, and `FontName`
    ///            with the font to use to show the characters.
    public static func GetCharacterSetInfo(_ For: CharacterSets) -> (Characters: String, FontName: String)
    {
        let CharListType = CharacterSetMap[For]!
        return (CharListType.rawValue, FontMap[CharListType]!)
    }
}

/// Characters for each associated character set.
enum CharacterLists: String, CaseIterable
{
    /// Set of flower-like symbols.
    case Flowers = "✻✾✢✥☘❅✽✤🟔✺✿🏵❁🙨🙪🏶❇❀❃❊✼🌻🌺🌹🌸🌷💐⚜✥🌼᪥ꕥꕤꙮ⚘❀❦"
    /// Set of snowflake-like symbols (or snow-related).
    case Snowflakes = "❄❆⛄🞾❉"
    /// Set of arrows/pointers of various types.
    case Arrows = "❮❯⇧⬀↯⮔☇⇨⮋⏎⬂⮍👎⇩⏪⮈⮎⮰⇪👍⮱⮶⮴⭪⬃🡇☝⭯⏩⇦☜⮊⬁⮇⮌⬄🠣⮏⮉⇳➘☞➙➚⮕⬊⬇⬋⬅☚☛⬉☟⬌⬍➢➳➶➵➴➹➾"
    /// Small geometric shapes.
    case SmallGeometry = "●○◐◑⏾◒◓◖⦿⬬◗◔⬒⯋⬢🙾🞆⬠⬡⬟⭖◕◊◍◌🞖⬯◉◎◙🛆◪🞐🞟⛋◆◇❖◬🞜◈⯄▰■□▢▣⬚▤▥▦▧▨▩◧◩◨"
    /// Set of star-like symbols.
    case Stars = "✦✧✩✪✯⋆✮✹✶🟊❂✴✵☀✺🟑✷🟑🟆☼✸🟏✰✬✫✭"
    /// Set of typographical ornaments.
    case Ornamental = "🎔🙞🙱🙟❛❜🙧❝🙝🙤🙜🙦🙥❢☙🙹🙢🙒🙚❧🙠❡🙘🙐❦❤🙰❟❣❠🙣🙓❞🙛🙡🙑🙙🙵🙖🙔🙗🙕"
    /// Get set of object symbols.
    case Things = """
    🖴🎧🌶⏳🏠🕹🖋🌜🎚⛟🖍🏱🎭🕾✂🛰⛔🖊🖉🕰🖫🌢⚾🕷🏆🎭🖩🏍⛏⏱📺🏔🌡🛧🛢👁🛦🙭⌚📹🎮🗑📦🛳📾🏎🔓📬📻🖐🚔📭💿🚇🎖🗝🖳🚘🚍🛱✐✈⛁⛂⛀⛃♨☁🔒☂🐦🐟🌎📽🕮🐈🛎🏭🌏🍽🖪🛲🚲🖁☎🛊🛏👪🐕🏙👽🕯🕬🌍📷☏🕊🎬🕫🐿🏝🕶📪☕⛄🛉✄✏🛩📚👂👓🛠🗺
    """
    /// Set of computer-related symbols.
    case Computers = "🗛🕹🖦🖮🖰␆🖶␡💿🗗⌨🎟␄🎮🗚🔇💻🖫🖲🖨⌧🔉🖬🖵␀🔊🖸⌫⏏🔈⌦🖴🖷␕"
    /// Set of Hiragana characters.
    case Hiragana = """
    あいうえおかがきぎくぐけげこごさざしじすずせぜそぞただちぢつづてでとどなにぬねのはばぱひびぴふぶぷへべぺほぼぽまみむめもやゆよらりるれろわゐゑをん
    """
    /// Set of Katakana characters.
    case Katakana = """
    アイウエオカガキギクグケゲコゴサザシジスズセゼソゾタダチヂツヅテデトドナニヌネノハバパヒビピフブプヘベペホボポマミムメモヤユヨラリルレロワヰヱヲンヴ
    """
    /// Set of grade school kanji.
    case KyoikuKanji = """
    一丁七万三上下不世両並中丸主久乗九乱乳予争事二五亡交京人仁今仏仕他付代令以仮仲件任休会伝似位低住体何余作使例供価便係保信修俳俵倉個倍候借値停健側備傷働像億優元兄兆先光児党入全八公六共兵具典内円冊再写冬冷処出刀分切刊列初判別利制刷券刻則前副割創劇力功加助努労効勇勉動務勝勢勤包化北区医十千午半卒協南単博印危卵厚原厳去参友反収取受口古句可台史右号司各合同名后向君否吸告周味呼命和品員唱商問善喜営器四回因団困囲図固国園土圧在地坂均垂型城域基堂報場塩境墓増士声売変夏夕外多夜夢大天太夫央失奏奮女好妹妻姉始委姿婦子字存孝季学孫宅宇守安完宗官宙定宝実客宣室宮害家容宿寄密富寒察寸寺対専射将尊導小少就尺局居届屋展属層山岩岸島川州巣工左差己巻市布希師席帯帰帳常幕干平年幸幹幼庁広序底店府度座庫庭康延建弁式弓引弟弱張強当形役往径待律後徒従得復徳心必志忘応忠快念思急性恩息悪悲情想意愛感態慣憲成我戦戸所手才打批承技投折担招拝拡拾持指挙捨授採探接推提揮損操支改放政故救敗教散敬数整敵文料断新方旅族旗日旧早明易昔星映春昨昭昼時晩景晴暑暖暗暮暴曜曲書最月有服朗望朝期木未末本札机材村束条来東松板林枚果枝染柱査栄校株根格案桜梅械棒森植検業極楽構様標模権横樹橋機欠次欲歌止正武歩歯歴死残段殺母毎毒比毛氏民気水氷永求池決汽河油治沿泉法波泣注泳洋洗活派流浅浴海消液深混清済減温測港湖湯満源準漁演漢潔潮激火灯灰災炭点無然焼照熟熱燃父片版牛牧物特犬犯状独率玉王班現球理生産用田由申男町画界畑留略番異疑病痛発登白百的皇皮皿益盛盟目直相省看県真眼着矢知短石砂研破確磁示礼社祖祝神票祭禁福私秋科秒秘移程税種穀積穴究空窓立章童競竹笑笛第筆等筋答策算管箱節築簡米粉精糖糸系紀約紅納純紙級素細終組経結給統絵絶絹続綿総緑線編練縦縮績織罪置署羊美群義羽翌習老考者耕耳聖聞職肉肥育肺胃背胸能脈脳腸腹臓臣臨自至興舌舎航船良色花芸芽若苦英茶草荷菜落葉著蒸蔵薬虫蚕血衆行術街衛衣表裁装裏補製複西要見規視覚覧親観角解言計討訓記訪設許訳証評詞試詩話誌認誕語誠誤説読課調談論諸講謝識警議護谷豆豊象貝負財貧貨責貯貴買貸費貿賀賃資賛賞質赤走起足路身車軍転軽輪輸辞農辺近返述迷追退送逆通速造連週進遊運過道達遠適選遺郡部郵郷都配酒酸里重野量金針鉄鉱銀銅銭鋼録鏡長門閉開間関閣防降限陛院除陸険陽隊階際障集雑難雨雪雲電青静非面革音頂順預領頭題額顔願類風飛食飯飲飼養館首馬駅験骨高魚鳥鳴麦黄黒鼻
    """
    /// Set of Hangul characters.
    case Hangul = """
    ㄱㄴㄷㄹㅁㅂㅅㅇㅈㅊㅋㅌㅍㅎㅏㅑㅓㅕㅗㅛㅜㅠㅡㅣㄲㄸㅃㅆㅉㅐㅒㅚㅔㅖㅙㅟㅞㅢㅝ가나다마버서어저처토포코호꾸뚜삐씨쯔
    """
    /// Set of Bodoni ornamental characters.
    case Bodoni = """
    !"#$%&()*+,�./012356789:;<=>?@ABCDEFGHIJKLMNOPQRSTVWXYZ][\\^_`abcdefghijklmnopqrstuvwxyz{|}†°¢®©™´¨≠ÆØ∞±≤≥¥�∂∑∏π∫’
    """
    /// Greek alphabet.
    case Greek = """
    ΑΒΓΔΕΖΗΘΙΚΛΜΝΞΟΠΡΣΤΥΦΧΨΩαβγδεζηθικλμνξορςστυφχψω
    """
    /// Cyrillic alphabet.
    case Cyrillic = """
    АаБбВвГгДдЕеЁёЖжЗзИиЙйКкЛлМмНнОоПпРрСсТтУуФфХхЦцЧчШшЩщЪъЫыЬьЭэЮюЯя
    """
    /// Set of various emoji characters.
    case Emoji = """
    ♑ℹ⌚⌛⏰⏳Ⓜ☀☁☺♈♉♊♋♌♍♎♏♐♒♓♠♣♥♦♨♻♿⚓⚠⚡⚽⚾⛄⛅⛎⛔⛪⛲⛳⛵⛺⛽✂
    ✈✉✊✋✌✏✒✨✳✴❄❇❤➰➿⭐〰〽㊗㊙🀄🃏🈁🈂🈚🈯🈲🈳🈴🈵🈶🈷🉑
    🌀🌁🌂🌃🌄🌅🌆🌇🌈🌉🌊🌋🌌🌏🌙🌛🌟🌠🌰🌱🌴🌵
    🌷🌸🌹🌺🌻🌼🌽🌾🌿🍀🍁🍂🍃🍄🍅🍆🍇🍈🍉🍊🍌🍍🍎🍏
    🍑🍒🍓🍔🍕🍖🍗🍘🍙🍚🍰🍛🍜🍝🍞🍟🍠🍡🍢🍣🍤🍥🍦🍧🍨
    🎆🎂🎁🎀🍸🍭🍪🍩🍫🍬🍮🍯🍱🍲🍳🍻🍵🍶🍷🍺🎃🎄🎅🎇🎈
    🎧🎉🎊🎋🎌🎎🎐🎏🎍🎑🎒🎓🎠🎥🎨🎩🎬🎫🎮🎯🎰🎱🎲🎳
    🐌🏯🏈🎻🎴🎵🎶🐙🎷🎸🎹🎺🎼🎽🎾🏁🏃🏢🏣🏫🏬🏭🏮🏰🐍🏥🏦
    🐢🐜🐦🐟🐠🐡🐤👓🐣🐥🐹🐚🐎🐔🐛🐝🐞🐑🐒🐗🐘👅👑🐩🐰🐺🐮🐴🐻
    👒👖👕👔🐧🐱🐲🐵👀👂👄🐬🐯🐶🐭🐳🐨🐫🐸🐼🐾🐷👗👘👙👚
    👛👟👢👣👤💇👧👫💠👩💔👪👮👴👵👷👾💄👺👽👿👻💀💅👨👶👹👜👝👡👦
    💖💟💣💤💘💜💞💳💗💙💡💢💚💫👞👠💈💓💛💕💝💋💍💏💑💌
    💥💪💺📆📇📌📏📑📋📎📐💴📍💸💹💵💬💦💨💩💰💲💯💱💧💮
    📜📷🔃🔎📚📞📡📺🔋🔔🔊🔐🔌🌘🔍📰📶🔏🔑📹📼📣📻🔒🔓📠📦📮
    📒📝📟📢📕📖🔲🔳🗼🚒🚓🚅🚇🚏🚕🚙🚧🚩🚤🚥🚚🚢󾓬🚨🚉🚑🚗🔖🔘🔤🔦
    🔴🗻🗽🚌🚃🚄🔨🔩🔱🗾🔮🔰🚀🔧🔪󾓨🔯🔥🌞🔗🔠🔢🔣🔡󾓮🏇🏉🌐
    🚪🚫🚭🚼🈹󾓦🐋󾓩󾓫🚠🐏🍐🚛🌍🌎🌝🌖🐊🔭🚍🚜🚝🌲🌗🌳🌒🚋🚟
    🍼🚊🚎🚞🍋🔬🛃🌜🚦🚰🚿🛁💭💶💷📵🚡🚣🛂🚽🚾🉐󾓥󾓧󾓪󾓭🏤📯
    🈺🚬🛀🈸🚲🐆🐕🐖👳🔀🔅🔆☕🐂🐇🐈🐐👱👲☑☔🚁🚂🐁🐄🐅🐉🐓☎
    🐀🐃
    """
    /// Set of common Latin characters.
    case Latin = """
    !"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[]^_`abcdefghijklmnopqrstuvwxya{|}~¡¢£¤¥¦§¨©ª«♪♫♯
    ¬­­®¯°±º¹²³´µØ¶·¸»½¾¼ÃÓÂÇÊËÏÐÑÎÒÄÍ­¿ÁÉÆÈÌÀÅĄÔÜâý×ÚßîñõøÿĀÞàáæçíðôûäêëïòöüăĩĭĮİċęĝĞĪĒĔėğĠīįĲĈďēĜĕĖĚĤħĬćĉčĎĐěĢģĥĦıãåèìó÷þÛÝúāĂČÕÖÙĊĨĘéùąđĆġĸĺļłŅŏ
    ņŇňŌőŖŎŊōŐŉŋŬŒŔŕĳĵĹĽľńœĴΌĶķĿŁŃĻŀŚŗřŞŠťŧŵūůűųŶżǼŜşȚŪŮŰŲŹŽžǽŝŦŴźŻȘśšțŤŨŭŷǺǾǿⁿ∆−√≠₤№℮∏∞∫◊ﬁ⁸€ℓΩ⅛⅜∑≈≤≥⁷₣₧™⅝⅞∂ΎΊŘŸș℅ΈũſΆ·ƒǻΈ⁴Ήΐ–―ﬂ‗‘’‚‛“”„—‡•‼⁄⁵†‰›…′″‹\\
    """
    /// Set of common punctuation characters.
    case Punctuation = """
    ¦'.@◊#(:;=<?_[`~,¢£¡{§}%½&*/$+>]^")-!|⁄\\¯´¶¨«®°·¬¥©±¼¤»¾‰∞∫¿―‗‚„•≠…″‹№—′›ℓΩ–‘’“”†‡‼€™−≈‛₤₧℅⅛⅜∂₵℮⅝⅞∑≥∆∏≤ȷ₮₯√₡₲₹₢₥₠₭₰₱₳⅓₦₩₨₴⅔℗⅍ⅎ≡⌂ↄ
    """
    /// Set of box symbols.
    case BoxSymbols = """
    ○◦◘─│┌┐└┘├┤┴┬╒┼║╖╗╘╚╞╦╕╙╟╛╜╠◙═╓╔╝╡╢╣╤╪╬╥╩╫╨╧▀▄█░▐▌▒▓■□◌●
    """
}


/// Shapes the program supports.
enum Shapes: String, CaseIterable
{
    //Built-in 3D shapes.
    /// Blocks created with SCNBox.
    case Blocks = "Blocks"
    /// Spheres created with SCNSphere.
    case Spheres = "Spheres"
    /// Cones created with SCNCone.
    case Cones = "Cones"
    /// Rings/donuts created with SCNTorus.
    case Rings = "Rings"
    /// Tubs created with SCNTube.
    case Tubes = "Tubes"
    /// Cylinders created with SCNCylinder.
    case Cylinders = "Cylinders"
    /// Pyramids created with SCNPyramids.
    case Pyramids = "Pyramids"
    /// Capsules created with SCNCapsule.
    case Capsules = "Capsules"
    
    //Non-standard extruded shapes.
    /// Equalaterial triangles. (In reality, just a three-sided polygon).
    case Triangles = "Triangles"
    /// General-purpose regular polygon.
    case Polygons = "Polygons"
    /// Star shape with varying number of apexes.
    case Stars = "Stars"
    /// Diamonds/parallelograms.
    case Diamonds = "Diamonds"
    /// Ovals.
    case Ovals = "Ovals"
    /// Lines (which are really nothing more than very skinny boxes).
    case Lines = "Lines"
    
    //Built-in or slightly modified 3D shapes as 2D shapes.
    /// Square shapes from very thin SCNBox shapes.
    case Squares = "Squares"
    /// Rectangle shapes from very thin SCNBox shapes.
    case Rectangles = "Rectangles"
    /// Circle shapes from very think SCNCylinder shapes.
    case Circles = "Circles"
    /// Very thin triangles.
    case Triangles2D = "2D Triangles"
    /// Very thin regular polygon.
    case Polygons2D = "2D Polygons"
    /// Very thin star shape.
    case Stars2D = "2D Stars"
    /// Very thin ovals.
    case Oval2D = "2D Ovals"
    /// Very think diamonds.
    case Diamond2D = "2D Diamonds"
    
    //Combined shapes.
    /// A line with another shape positioned at the bottom, middle or top. The default "other" shape
    /// is a sphere, which seems to work best.
    case CappedLines = "Capped Lines"
    /// Two squares intersecting on perpendicular planes.
    case PerpendicularSquares = "Perpendicular Squares"
    /// Two circles intersecting on perpendicular planes.
    case PerpendicularCircles = "Perpendicular Circles"
    /// Three triangles that touch.
    case ThreeTriangles = "Three Triangles"
    /// Radiating lines. Line count varies depending on the user.
    case RadiatingLines = "Radiating Lines"
    /// Blocks with an extruded shape determined by the user.
    case BlockBases = "Blocks+"
    /// Spheres with an extruded shape determined by the user.
    case SphereBases = "Spheres+"
    
    //Variable shapes.
    /// Shape that is made of stacked sub-shapes that vary depending on the selected color component.
    case ComponentVariable = "Component Varying"
    
    //Complex shapes.
    /// Arrow head shapes that point to the color's hue.
    case HueTriangles = "Hue Triangles"
    /// Extruded charaters.
    case Characters = "Characters"
    
    //Dynamic shapes.
    /// Particle emitter.
    case Particles = "Particles"
    
    //Special case for no shape.
    /// No shape specified.
    case NoShape = "NoShape"
}
