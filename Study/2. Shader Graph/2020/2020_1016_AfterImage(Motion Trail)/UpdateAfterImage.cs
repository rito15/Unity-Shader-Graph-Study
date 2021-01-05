using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class UpdateAfterImage : MonoBehaviour
{
    public Material[] _afterImageMaterials; // 잔상 마테리얼들을 차례로 등록
    public float _updateCycle = 0.03f;      // 잔상 업데이트 주기

    // 포지션 보정
    public Vector3 _posOffset;


    // _afterImageMaterials 길이
    private int _aiMatLen;
    private int _recordLen; // _aiMatLen + 1

    //[SerializeField]
    private int _recordIndex = 0;

    //[SerializeField]
    private Vector3[] _moveRecord; // 지난 이동 기록

    //[SerializeField]
    private Vector3[] _adjustedMoveRecord; // 0부터 현재 ~ maxLen까지 가장 오래된 이동 기록으로 조정


    private Renderer _renderer;

    private void Awake()
    {
        _aiMatLen = _afterImageMaterials.Length;
        _recordLen = _aiMatLen + 1;

        _moveRecord = new Vector3[_recordLen];
        _adjustedMoveRecord = new Vector3[_recordLen];
    }

    private void Start()
    {
        TryGetComponent(out _renderer);
        if (_renderer)
        {
            Material[] newMats = new Material[_aiMatLen + 1];

            newMats[0] = _renderer.material;

            for (int i = 1; i < _aiMatLen + 1; i++)
            {
                newMats[i] = Instantiate(_afterImageMaterials[i - 1]); // 각각 잔상 마테리얼 클론 생성
                _afterImageMaterials[i - 1] = newMats[i];
            }

            _renderer.materials = newMats;
        }

        // 마테리얼 초기 위치 설정
        for (int i = 0; i < _aiMatLen; i++)
        {
            _afterImageMaterials[i].SetVector("_Position", transform.position + _posOffset);
        }


        StartCoroutine(UpdateRoutine());
    }

    private void Update()
    {
        UpdateAfterImages();
    }

    private IEnumerator UpdateRoutine()
    {
        while (true)
        {
            _moveRecord[_recordIndex] = transform.position;

            for (int i = 0; i < _recordLen; i++)
            {
                _adjustedMoveRecord[i] = _moveRecord[(_recordIndex + _aiMatLen + 1 - i) % (_recordLen)];
            }

            _recordIndex = (_recordIndex + 1) % _recordLen;

            yield return new WaitForSeconds(_updateCycle);
        }
    }

    private void UpdateAfterImages()
    {
        if (_afterImageMaterials == null || _aiMatLen == 0 || _renderer == null)
            return;

        for (int i = 0; i < _aiMatLen; i++)
        {
            _afterImageMaterials[i].SetVector("_Position",
                    _adjustedMoveRecord[i + 1] + _posOffset
                );
        }
    }
}
