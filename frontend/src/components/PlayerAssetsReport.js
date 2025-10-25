import React from 'react';
import './PlayerAssetsReport.css';

const PlayerAssetsReport = ({ data, loading, error, onRefresh }) => {
  if (loading) {
    return (
      <div className="card shadow-lg">
        <div className="card-body text-center py-5">
          <div className="spinner-border text-primary mb-3" role="status">
            <span className="visually-hidden">Loading...</span>
          </div>
          <p className="text-muted">Đang tải dữ liệu...</p>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="card shadow-lg">
        <div className="card-body">
          <div className="alert alert-danger d-flex align-items-center" role="alert">
            <div>
              <strong>Lỗi!</strong> {error}
            </div>
          </div>
          <div className="text-center">
            <button className="btn btn-primary" onClick={onRefresh}>
              <i className="bi bi-arrow-clockwise"></i> Thử lại
            </button>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="card shadow-lg report-card">
      <div className="card-header bg-primary text-white">
        <div className="d-flex justify-content-between align-items-center">
          <h2 className="mb-0 h4">
            <i className="bi bi-file-earmark-text"></i> Báo cáo Tài sản Người chơi
          </h2>
          <button 
            className="btn btn-light btn-sm" 
            onClick={onRefresh}
            title="Làm mới dữ liệu"
          >
            <i className="bi bi-arrow-clockwise"></i> Làm mới
          </button>
        </div>
      </div>
      <div className="card-body p-0">
        {data && data.length > 0 ? (
          <div className="table-responsive">
            <table className="table table-hover table-striped mb-0">
              <thead className="table-dark">
                <tr>
                  <th className="text-center" style={{ width: '80px' }}>No</th>
                  <th>Player name</th>
                  <th className="text-center" style={{ width: '100px' }}>Level</th>
                  <th className="text-center" style={{ width: '100px' }}>Age</th>
                  <th>Asset name</th>
                </tr>
              </thead>
              <tbody>
                {data.map((item, index) => (
                  <tr key={index} className="table-row-animated">
                    <td className="text-center fw-bold">{item.No}</td>
                    <td>
                      <div className="d-flex align-items-center">
                        <div className="player-avatar me-2">
                          {item.PlayerName.charAt(0).toUpperCase()}
                        </div>
                        <span className="fw-semibold">{item.PlayerName}</span>
                      </div>
                    </td>
                    <td className="text-center">
                      <span className="badge bg-info">{item.Level}</span>
                    </td>
                    <td className="text-center">{item.Age}</td>
                    <td>
                      <span className="asset-badge">
                        <i className="bi bi-gem"></i> {item.AssetName}
                      </span>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        ) : (
          <div className="text-center py-5">
            <div className="mb-3">
              <i className="bi bi-inbox" style={{ fontSize: '3rem', color: '#ccc' }}></i>
            </div>
            <p className="text-muted">Không có dữ liệu để hiển thị</p>
            <p className="text-muted small">
              Hãy đảm bảo đã có dữ liệu trong database và API đang hoạt động
            </p>
          </div>
        )}
      </div>
      {data && data.length > 0 && (
        <div className="card-footer bg-light">
          <div className="d-flex justify-content-between align-items-center">
            <span className="text-muted">
              Tổng số bản ghi: <strong>{data.length}</strong>
            </span>
            <span className="text-muted small">
              <i className="bi bi-clock"></i> Cập nhật: {new Date().toLocaleString('vi-VN')}
            </span>
          </div>
        </div>
      )}
    </div>
  );
};

export default PlayerAssetsReport;

