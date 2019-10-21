package;

import haxe.Int32;
import com.hurlant.util.ByteArray;
import com.hurlant.crypto.Crypto;
import com.hurlant.crypto.symmetric.ICipher;
import com.hurlant.crypto.encoding.binary.Base64;
import com.hurlant.crypto.pad.NullPad;

class NgCrypto {

	private var key:ByteArray;
	private var b64:Base64 = new Base64();
	
	public function new(encryption_key:String) {
		this.key = this.b64.decode(encryption_key);
	}
	
	public function encrypt(input:String, charSet:String="utf-8"):String {
		var encrypted:ByteArray = new ByteArray();
		encrypted.writeMultiByte(input, charSet);
        encrypted.position = 0;
		
		var pad:NullPad = new NullPad();
		var cipher:ICipher = Crypto.getCipher("simple-aes128", this.key, pad);
		pad.setBlockSize(cipher.getBlockSize());
		
		cipher.encrypt(encrypted);
		
		return (this.b64.encode(encrypted));
	}
}
