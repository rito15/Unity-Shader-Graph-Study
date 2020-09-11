
using UnityEngine;

public class Test_DissolveController : MonoBehaviour
{
    public Renderer _dissolveTarget;
    public Material _mat;

    public float _dissolveValue = 0f;

    private void Start()
    {
        if (_dissolveTarget)
            _mat = _dissolveTarget.material;
    }

    private void Update()
    {
        if (_mat == null)
        {
            Debug.LogWarning("Dissolve : 대상 마테리얼이 null입니다.");
            return;
        }

        if      (Input.GetKey(KeyCode.Q)) Dissolve();
        else if (Input.GetKey(KeyCode.E)) Show();
    }

    private void Dissolve()
    {
        Debug.Log("DISSOLVE");

        _dissolveValue = Mathf.Clamp(_dissolveValue + 0.01f, 0f, 1f);

        _mat.SetFloat("_Dissolve", _dissolveValue);
    }

    private void Show()
    {
        Debug.Log("SHOW");

        _dissolveValue = Mathf.Clamp(_dissolveValue - 0.01f, 0f, 1f);

        _mat.SetFloat("_Dissolve", _dissolveValue);
    }
}