using UnityEngine;
using System.Collections;

public class GameOfLife : MonoBehaviour {

	private RenderTexture[] _buffer;

	public  int BufferWidth  = 512;
	public  int BufferHeight = 512;

	public  float MouseX = 0.0f;
	public  float MouseY = 0.0f;

	public Shader ConwayShader;
	private Material _conwayMat;

	private bool _pingPong = false;

	void Start () {

		_buffer = new RenderTexture[2];
		_buffer[0] = new RenderTexture (BufferWidth, BufferHeight, 0, RenderTextureFormat.ARGB32);
		_buffer[0].anisoLevel   = 0;
		_buffer[0].antiAliasing = 1;
		_buffer[0].filterMode   = FilterMode.Point;
		_buffer[0].hideFlags    = HideFlags.DontSave;
		_buffer[0].Create ();

		_buffer[1] = new RenderTexture (BufferWidth, BufferHeight, 0, RenderTextureFormat.ARGB32);
		_buffer[1].anisoLevel   = 0;
		_buffer[1].antiAliasing = 1;
		_buffer[1].filterMode   = FilterMode.Point;
		_buffer[1].hideFlags    = HideFlags.DontSave;
		_buffer[1].Create ();

		_conwayMat = new Material (ConwayShader);

		transform.localScale = new Vector3 (
			transform.localScale.x * (Screen.width/(Screen.height*1.0f)),
			transform.localScale.y,
			transform.localScale.z
		);

	}

	void Update () {

		Vector3 mouse = Input.mousePosition;
		Vector3 vp    = Camera.main.ScreenToViewportPoint (mouse);
		MouseX = vp.x;
		MouseY = vp.y;

		_conwayMat.SetVector ("_Mouse",      new Vector2 (vp.x, vp.y));
		_conwayMat.SetVector ("_Resolution", new Vector2 (BufferWidth, BufferHeight));
		Graphics.Blit (_buffer[_pingPong ? 0 : 1], _buffer[_pingPong ? 1 : 0], _conwayMat);

		_pingPong = _pingPong ? false : true;

		renderer.material.SetTexture ("_MainTex", _buffer [0]);

	}

	void OnDestroy () {

		Destroy (_conwayMat);

		_buffer[0].Release ();
		Destroy (_buffer[0]);
		_buffer[0] = null;
		_buffer[1].Release ();
		Destroy (_buffer[1]);
		_buffer[1] = null;

	}
}
